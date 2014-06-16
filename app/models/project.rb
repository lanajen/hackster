class Project < ActiveRecord::Base
  FILTERS = {
    'featured' => :featured,
    'wip' => :wip,
  }
  SORTING = {
    'magic' => :magic_sort,
    'popular' => :most_popular,
    'recent' => :last_public,
    'updated' => :last_updated,
    'respected' => :most_respected,
  }

  include Counter
  include Privatable
  include StringParser
  include Taggable
#  include Workflow
  is_impressionable counter_cache: true, unique: :session_hash

  belongs_to :assignment, foreign_key: :collection_id
  belongs_to :event, foreign_key: :collection_id
  belongs_to :team
  has_many :active_users, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'")}, through: :team_members, source: :user
  has_many :awards
  has_many :blog_posts, as: :threadable, dependent: :destroy
  has_many :comments, -> { order created_at: :asc }, as: :commentable, dependent: :destroy
  # below is a hack because commenters try to add order by comments created_at and pgsql doesn't like it
  has_many :comments_copy, as: :commentable, dependent: :destroy, class_name: 'Comment'
  has_many :commenters, -> { uniq true }, through: :comments_copy, source: :user
  has_many :follow_relations, as: :followable
  has_many :followers, through: :follow_relations, source: :user
  has_many :issues, as: :threadable, dependent: :destroy
  has_many :images, as: :attachable, dependent: :destroy
  has_many :grades
  has_many :permissions, as: :permissible
  has_many :respects, dependent: :destroy, class_name: 'Respect'
  has_many :respecting_users, -> { order 'respects.created_at ASC' }, through: :respects, source: :respecting, source_type: User
  has_many :slug_histories, -> { order updated_at: :desc }, as: :sluggable, dependent: :destroy
  has_many :team_members, through: :team, source: :members#, -> { includes :user }
  has_many :users, through: :team_members
  has_many :widgets, -> { order position: :asc }, dependent: :destroy
  has_one :logo, as: :attachable, class_name: 'Avatar', dependent: :destroy
  has_one :cover_image, as: :attachable, class_name: 'CoverImage', dependent: :destroy
  has_one :video, as: :recordable, dependent: :destroy

  sanitize_text :description
  attr_accessible :description, :end_date, :name, :start_date, :current,
    :team_members_attributes, :website, :one_liner, :widgets_attributes,
    :featured, :featured_date, :cover_image_id, :logo_id, :license, :slug,
    :permissions_attributes, :new_slug, :slug_histories_attributes, :hide,
    :collection_id, :graded, :wip, :columns_count, :external, :guest_name,
    :approved
  attr_accessor :current
  attr_writer :new_slug
  accepts_nested_attributes_for :images, :video, :logo, :team_members,
    :widgets, :cover_image, :permissions, :slug_histories, allow_destroy: true

  validates :name, presence: true, length: { in: 3..100 }
  validates :one_liner, :logo, presence: true, if: proc { |p| p.force_basic_validation? }
  validates :one_liner, length: { maximum: 140 }
  validates :new_slug,
    format: { with: /\A[a-z0-9_\-]+\z/, message: "accepts only downcase letters, numbers, dashes '-' and underscores '_'." },
    length: { maximum: 105 }, allow_blank: true
  validates :new_slug, presence: true, if: proc{ |p| p.persisted? }
  with_options if: proc {|p| p.external } do |project|
    project.validates :website, :one_liner, :cover_image, presence: true
    project.before_save :external_is_hidden
  end
  validates :website, uniqueness: { message: 'has already been submitted' }, allow_blank: true
  validates :guest_name, length: { minimum: 3 }, allow_blank: true
  validate :slug_is_unique
  before_validation :assign_new_slug
  before_validation :check_if_current
  before_validation :clean_permissions
  before_validation :ensure_website_protocol
  before_create :set_columns_count
  before_save :generate_slug, if: proc {|p| !p.persisted? or p.team_id_changed? }

  taggable :product_tags, :tech_tags

  store :counters_cache, accessors: [:comments_count, :product_tags_count,
    :widgets_count, :followers_count, :build_logs_count,
    :issues_count, :team_members_count]

  parse_as_integers :counters_cache, :comments_count, :product_tags_count,
    :widgets_count, :followers_count, :build_logs_count,
    :issues_count, :team_members_count

  self.per_page = 16

  # beginning of search methods
  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name ELASTIC_SEARCH_INDEX_NAME

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 100
      indexes :one_liner,       analyzer: 'snowball'
      indexes :product_tags,    analyzer: 'snowball', boost: 50
      indexes :tech_tags,       analyzer: 'snowball', boost: 50
#      indexes :description,     analyzer: 'snowball'
      indexes :text_widgets,    analyzer: 'snowball'
      indexes :user_names,      analyzer: 'snowball'
      indexes :private,         analyzer: 'keyword'
      indexes :hide,            analyzer: 'keyword'
      indexes :external,        analyzer: 'keyword'
      indexes :approved,        analyzer: 'keyword'
      indexes :created_at
    end
  end

  def to_indexed_json
    {
      _id: id,
      name: name,
      model: self.class.name,
      one_liner: one_liner,
#      description: description,
      product_tags: product_tags_string,
      tech_tags: tech_tags_string,
      text_widgets: TextWidget.where('widgets.project_id = ?', id).map{ |w| w.content },
      user_name: team_members.map{ |t| t.user.try(:name) },
      private: private,
      hide: hide,
      external: external,
      approved: approved,
      created_at: created_at,
    }.to_json
  end
  # end of search methods

  def self.approved
    where(approved: true)
  end

  def self.approval_needed
    where(approved: nil)
  end

  def self.external
    where(external: true)
  end

  def self.featured
    indexable.where(featured: true).order(featured_date: :desc)
  end

  def self.indexable
    live.where(hide: false)
  end

  def self.indexable_and_external
    where("(projects.private = 'f' AND projects.hide = 'f') OR (projects.external = 't' AND projects.approved = 't')").magic_sort
  end

  def self.live
    where(private: false, approved: true)
  end

  def self.last_created
    order('projects.created_at DESC')
  end

  def self.last_public
    order('projects.made_public_at DESC')
  end

  def self.last_updated
    order('projects.updated_at DESC')
  end

  def self.magic_sort
    order('projects.popularity_counter DESC').order('projects.created_at DESC')
  end

  def self.most_popular
    order('projects.impressions_count DESC')
  end

  def self.most_respected
    order('projects.respects_count DESC')
  end

  def self.wip
    indexable.where(wip: true).last_updated
  end

  def age
    (Time.now - created_at) / 86400
  end

  def all_issues
    (issues + Issue.where(threadable_type: 'Widget').where('threadable_id IN (?)', widgets.pluck('widgets.id'))).sort_by{ |t| t.created_at }
  end

  def assign_new_slug
    @old_slug = slug
    self.slug = new_slug
  end

  def compute_popularity
    self.popularity_counter = ((respects_count * 2 + impressions_count * 0.1 + followers_count * 2 + comments_count * 5 + featured.to_i * 10) * [[(1.to_f / Math.log10(age)), 10].min, 0.01].max).round(4) * (public and !hide).to_i
  end

  def columns_count
    layout.to_i
  end

  def columns_count=(val)
    self.layout = val
  end

  def counters
    {
      build_logs: 'blog_posts.count',
      comments: 'comments.count',
      followers: 'followers.count',
      issues: 'issues.count',
      product_tags: 'product_tags.count',
      respects: 'respects.count',
      team_members: 'users.count',
      widgets: 'widgets.count',
    }
  end

  def cover_image_id=(val)
    self.cover_image = CoverImage.find_by_id(val)
  end

  def force_basic_validation!
    @force_basic_validation = true
  end

  def force_basic_validation?
    @force_basic_validation
  end

  def guest_or_user_name
    guest_name.presence || users.first.try(:name)
  end

  def hidden?
    hide
  end

  def image
    images.first
  end

  def is_assignment?
    collection_id.present? and assignment.present?
  end

  def license
    return @license if @license
    val = read_attribute(:license)
    @license = License.new val if val.present?
  end

  def logo_id=(val)
    self.logo = Avatar.find_by_id(val)
  end

  def new_slug
    @new_slug ||= slug
  end

  def slug_was_changed?
    @old_slug.present? and @old_slug != slug
  end

  # def to_param
    # "#{id}-#{name.gsub(/[^a-zA-Z0-9]/, '-').gsub(/(\-)+$/, '')}"
  # end

  def to_tracker
    {
      comments_count: comments_count,
      external: external,
      has_logo: logo.present?,
      is_featured: featured,
      is_public: public?,
      project_id: id,
      project_name: name,
      product_tags_count: product_tags_count,
      respects_count: respects_count,
      views_count: impressions_count,
      widgets_count: widgets_count,
    }
  end

  def update_slug
    generate_slug unless slug_was_changed?
  end

  def update_slug!
    update_slug
    save validate: false
  end

  def uri user_name=user_name_for_url
    "#{user_name}/#{slug}"
  end

  def user_name_for_url
    user_name_from_guest_name.presence || team.try(:user_name).presence || id
  end

  def user_name_from_guest_name
    return unless guest_name

    I18n.transliterate(guest_name).gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
  end

  def widgets_first_col
    widgets.first_column
  end

  def widgets_second_col
    widgets.second_column
  end

  def wip?
    wip
  end

  private
    def can_be_public?
      widgets_count >= 1 and cover_image.try(:file).present?
    end

    def check_if_current
      self.end_date = nil if current
    end

    def clean_permissions
      permissions.each do |permission|
        permissions.delete(permission) if permission.new_record? and permission.grantee.nil?
      end
    end

    def ensure_website_protocol
      return unless website_changed? and website.present?
      self.website = 'http://' + website unless website =~ /^http/
    end

    def external_is_hidden
      self.hide = true
    end

    def generate_slug
      slug = I18n.transliterate(name).gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
      parent = team ? self.class.joins(:team).where(groups: { user_name: team.user_name }).where.not(id: id) : self.class.where(team_id: 0).where.not(id: id)

      # make sure it doesn't exist
      if result = parent.where(projects: {slug: slug}).any?
        # if it exists add a 1 and increment it if necessary
        slug += '1'
        while parent.where(projects: {slug: slug}).any?
          slug.succ!
        end
      end
      self.slug = slug
    end

    def set_columns_count
      self.columns_count = 1
    end

    def slug_is_unique
      return unless slug_changed?

      parent = team ? self.class.joins(:team).where(groups: { user_name: team.user_name }) : self.class
      errors.add :new_slug, 'has already been taken' if parent.where(projects: { slug: slug }).where.not(id: id).any?
    end
end
