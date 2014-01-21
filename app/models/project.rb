class Project < ActiveRecord::Base
  include Counter
  include Privatable
  include StringParser
  include Taggable
#  include Workflow
  is_impressionable counter_cache: true, unique: :session_hash

  belongs_to :team
  has_and_belongs_to_many :followers, class_name: 'User', join_table: 'project_followers'
  has_many :blog_posts, as: :threadable, dependent: :destroy
  has_many :comments, -> { order created_at: :asc }, as: :commentable
  has_many :issues, as: :threadable, dependent: :destroy
  has_many :images, as: :attachable, dependent: :destroy
  has_many :permissions, as: :permissible
  has_many :respects, dependent: :destroy, class_name: 'Favorite'
  has_many :respecting_users, -> { order 'favorites.created_at ASC' }, through: :respects, source: :user
  has_many :slug_histories, -> { order updated_at: :desc }, dependent: :destroy
  has_many :team_members, through: :team, source: :members#, -> { includes :user }
  has_many :users, through: :team_members
  has_many :widgets, -> { order position: :asc }
  has_one :logo, as: :attachable, class_name: 'Avatar'
  has_one :cover_image, as: :attachable, class_name: 'CoverImage'
  has_one :video, as: :recordable, dependent: :destroy

  sanitize_text :description
  attr_accessible :description, :end_date, :name, :start_date, :current,
    :team_members_attributes, :website, :one_liner, :widgets_attributes,
    :featured, :featured_date, :cover_image_id, :logo_id, :license, :slug,
    :permissions_attributes, :new_slug, :slug_histories_attributes
  attr_accessor :current
  attr_writer :new_slug
  accepts_nested_attributes_for :images, :video, :logo, :team_members,
    :widgets, :cover_image, :permissions, :slug_histories, allow_destroy: true

  validates :name, presence: true
  validates :name, length: { in: 3..100 }
  validates :one_liner, :logo, presence: true, if: proc { |p| p.force_basic_validation? }
  validates :one_liner, length: { maximum: 140 }
  validates :new_slug,
    format: { with: /\A[a-z0-9_\-]+\z/, message: "accepts only downcase letters, numbers, dashes '-' and underscores '_'." },
    length: { maximum: 105 }, allow_blank: true
  validates :new_slug, presence: true, if: proc{ |p| p.persisted? }
  validate :slug_is_unique
  before_validation :assign_new_slug
  before_validation :check_if_current
  before_validation :clean_permissions
  before_validation :ensure_website_protocol
  before_save :generate_slug, if: proc {|p| !p.persisted? or p.team_id_changed? }

  taggable :product_tags, :tech_tags

  store :counters_cache, accessors: [:comments_count, :product_tags_count, :respects_count, :widgets_count]

  parse_as_integers :counters_cache, :comments_count, :product_tags_count, :respects_count, :widgets_count

  self.per_page = 12

  # beginning of search methods
  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name BONSAI_INDEX_NAME

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 100
      indexes :one_liner,       analyzer: 'snowball'
      indexes :product_tags,    analyzer: 'snowball', boost: 50
#      indexes :tech_tags,       analyzer: 'snowball'
#      indexes :description,     analyzer: 'snowball'
      indexes :text_widgets,    analyzer: 'snowball'
      indexes :user_names,      analyzer: 'snowball'
      indexes :private,         analyzer: 'keyword'
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
#      tech_tags: tech_tags_string,
      text_widgets: TextWidget.where('widgets.project_id = ?', id).map{ |w| w.content },
      user_name: team_members.map{ |t| t.user.try(:name) },
      private: private,
      created_at: created_at,
    }.to_json
  end
  # end of search methods

  def self.featured
    indexable.where(featured: true).order(featured_date: :desc)
  end

  def self.indexable
    where(private: false)
  end

  def self.live
    indexable
  end

  def self.last_created
    indexable.order('projects.create_at DESC')
  end

  def self.last_public
    indexable.order('projects.made_public_at DESC')
  end

  def self.last_updated
    indexable.order('projects.updated_at DESC')
  end

  def self.most_popular
    indexable.order('projects.impressions_count DESC')
  end

  def all_issues
    (issues + Issue.where(threadable_type: 'Widget').where('threadable_id IN (?)', widgets.pluck('widgets.id'))).sort_by{ |t| t.created_at }
  end

  def assign_new_slug
    @old_slug = slug
    self.slug = new_slug
  end

  def counters
    {
      comments: 'comments.count',
      product_tags: 'product_tags.count',
      respects: 'respects.count',
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

  def image
    images.first
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
    team.try(:user_name).presence || 'non_attributed'
  end

  def widgets_first_col
    widgets.first_column
  end

  def widgets_second_col
    widgets.second_column
  end

  private
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

    def generate_slug
      slug = name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
      user_name = team ? team.user_name : ['', nil]
      parent = self.class.joins(:team).where(groups: { user_name: user_name }).where.not(id: id)

      # make sure it doesn't exist
      if result = parent.where(projects: {slug: slug}).any?
        # if it exists add a 1 and increment it if necessary
        slug += '1'
        while parent.where(projects: {slug: slug}).any?
          slug.gsub!(/([0-9]+$)/, ($1.to_i + 1).to_s)
        end
      end
      self.slug = slug
    end

    def slug_is_unique
      return unless slug_changed?

      parent = team ? self.class.joins(:team).where(groups: { user_name: team.user_name }) : self.class
      errors.add :new_slug, 'has already been taken' if parent.where(projects: { slug: slug }).where.not(id: id).any?
    end
end
