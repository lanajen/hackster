class Project < ActiveRecord::Base
  DEFAULT_NAME = 'Untitled'

  FILTERS = {
    'featured' => :featured,
    'featured_by_tech' => :featured_by_tech,
    'wip' => :wip,
  }
  SORTING = {
    'magic' => :magic_sort,
    'trending' => :magic_sort,
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
  has_many :group_relations, dependent: :destroy
  has_many :issues, as: :threadable, dependent: :destroy
  has_many :images, as: :attachable, dependent: :destroy
  has_many :grades
  has_many :permissions, as: :permissible
  has_many :respects, dependent: :destroy, class_name: 'Respect'
  has_many :respecting_users, -> { order 'respects.created_at ASC' }, through: :respects, source: :respecting, source_type: User
  has_many :slug_histories, -> { order updated_at: :desc }, as: :sluggable, dependent: :destroy
  has_many :team_members, through: :team, source: :members#, -> { includes :user }
  # has_many :groups, through: :group_relations
  has_many :teches, -> { where ("groups.type = 'Tech'") }, through: :group_relations, source: :group
  has_many :users, through: :team_members
  has_many :widgets, -> { order position: :asc }, as: :widgetable, dependent: :destroy
  has_one :logo, as: :attachable, class_name: 'Avatar', dependent: :destroy
  has_one :cover_image, as: :attachable, class_name: 'CoverImage', dependent: :destroy
  has_one :video, as: :recordable, dependent: :destroy

  # sanitize_text :description
  register_sanitizer :remove_whitespaces_from_html, :before_save, :description
  attr_accessible :description, :end_date, :name, :start_date, :current,
    :team_members_attributes, :website, :one_liner, :widgets_attributes,
    :featured, :featured_date, :cover_image_id, :logo_id, :license, :slug,
    :permissions_attributes, :new_slug, :slug_histories_attributes, :hide,
    :collection_id, :graded, :wip, :columns_count, :external, :guest_name,
    :approved, :open_source, :buy_link, :private_logs, :private_issues
  attr_accessor :current
  attr_writer :new_slug
  accepts_nested_attributes_for :images, :video, :logo, :team_members,
    :widgets, :cover_image, :permissions, :slug_histories, allow_destroy: true

  validates :name, length: { in: 3..100 }, allow_blank: true
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
  validates :website, uniqueness: { message: 'has already been submitted' }, allow_blank: true, if: proc {|p| p.website_changed? }
  validates :guest_name, length: { minimum: 3 }, allow_blank: true
  validate :slug_is_unique
  before_validation :assign_new_slug
  # before_validation :check_if_current
  before_validation :clean_permissions
  before_validation :ensure_website_protocol
  before_update :update_slug, if: proc{|p| p.name_was == DEFAULT_NAME and p.name_changed? }
  # before_create :set_columns_count
  before_save :generate_slug, if: proc {|p| !p.persisted? or p.team_id_changed? }

  taggable :product_tags, :tech_tags

  store :counters_cache, accessors: [:comments_count, :product_tags_count,
    :widgets_count, :followers_count, :build_logs_count,
    :issues_count, :team_members_count, :tech_tags_count]

  store :properties, accessors: [:private_logs, :private_issues]

  parse_as_integers :counters_cache, :comments_count, :product_tags_count,
    :widgets_count, :followers_count, :build_logs_count,
    :issues_count, :team_members_count, :tech_tags_count

  parse_as_booleans :properties, :private_logs, :private_issues

  self.per_page = 16

  # beginning of search methods
  include Tire::Model::Search
  # include Tire::Model::Callbacks
  index_name ELASTIC_SEARCH_INDEX_NAME

  after_save do
    if private or hide or !approved
      IndexerQueue.perform_async :remove, self.class.name, self.id
    else
      IndexerQueue.perform_async :store, self.class.name, self.id
    end
  end
  after_destroy do
    # tricky to move to background; by the time it's processed the model might not exist
    self.index.remove self
  end

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 100
      indexes :product_tags,    analyzer: 'snowball', boost: 50
      indexes :tech_tags,       analyzer: 'snowball', boost: 50
      indexes :description,     analyzer: 'snowball'
      indexes :one_liner,       analyzer: 'snowball'
      indexes :user_names,      analyzer: 'snowball'
      indexes :created_at
    end
  end

  def to_indexed_json
    {
      _id: id,
      name: name,
      model: self.class.name.underscore,
      one_liner: one_liner,
      description: description,
      product_tags: product_tags_string,
      tech_tags: tech_tags_string,
      user_name: team_members.map{ |t| t.user.try(:name) },
      created_at: created_at,
      popularity: popularity_counter,
    }.to_json
  end

  def self.index_all
    index.import approved.indexable_and_external
  end
  # end of search methods

  def self.approved
    where.not(approved: false)
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

  # assumes that the join with group_relations has already been done
  def self.featured_by_tech
    indexable.where(group_relations: { workflow_state: 'featured' }).order('group_relations.updated_at DESC')
  end

  def self.for_thumb_display
    includes(:users).includes(:cover_image).includes(:team)
  end

  def self.indexable
    live.where(approved: true, hide: false)
  end

  def self.indexable_and_external
    where("(projects.approved = 't' AND projects.private = 'f' AND projects.hide = 'f') OR (projects.external = 't' AND projects.approved <> 'f')")#.magic_sort
  end

  def self.live
    where(private: false)
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

  def buy_link_host
    URI.parse(buy_link).host.gsub(/^www\./, '')
  rescue
    buy_link
  end

  def compute_popularity time_period=365
    self.popularity_counter = ((respects_count * 4 + impressions_count * 0.05 + comments_count * 2 + featured.to_i * 10) * [1 - [(Math.log(age, time_period)), 1].min, 0.001].max).round(4)
  end

  def columns_count
    layout.to_i
  end

  def columns_count=(val)
    self.layout = val
  end

  def counters
    {
      build_logs: 'blog_posts.published.count',
      comments: 'comments.count',
      followers: 'followers.count',
      issues: 'issues.where(type: "Issue").count',
      product_tags: 'product_tags_cached.count',
      respects: 'respects.count',
      team_members: 'users.count',
      tech_tags: 'tech_tags_cached.count',
      widgets: 'widgets.count',
    }
  end

  def cover_image_id=(val)
    self.cover_image = CoverImage.find_by_id(val)
  end

  def credit_lines
    @credit_lines ||= credits_widget.try(:credit_lines) || []
  end

  def credits_widget
    @credits_widget ||= CreditsWidget.where(widgetable_id: id, widgetable_type: 'Project').first_or_create
  end

  def disable_tweeting?
    assignment.present?
  end

  def force_basic_validation!
    @force_basic_validation = true
  end

  def force_basic_validation?
    @force_basic_validation
  end

  def force_hide?
    assignment.try(:hide_all)
  end

  def generate_description_from_widgets
    self.description = widgets_to_text

    give_embed_style!
  end

  def give_embed_style!
    doc = Nokogiri::HTML::DocumentFragment.parse description

    doc.css('.embed-frame').each do |node|
      if node.next
        next_node = node.next

        @continue = true
        while @continue and next_node do
          @continue = false

          if next_node.attr('class') and next_node.attr('class').split(' ').include? 'embed-frame'
            node.set_attribute 'class', "#{node.attr('class')} followed-by-embed-frame"
          elsif next_node.name == 'h3'
            node.set_attribute 'class', "#{node.attr('class')} followed-by-h3"
          elsif next_node.content.strip.blank?
            @continue = true
            old_node = next_node
            next_node = old_node.next
            old_node.remove
          end
        end
      end

      if node.previous and node.previous.name == 'h3'
        node.set_attribute 'class', "#{node.attr('class')} preceded-by-h3"
      end
    end

    self.description = doc.to_html
  end

  def guest_or_user_name
    guest_name.presence || users.first.try(:name)
  end

  # def has_been_tweeted?
  #   tweed_id.present?
  # end

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

  def name
    super.presence || DEFAULT_NAME
  end

  def new_slug
    @new_slug ||= slug
  end

  def security_token
    Digest::MD5.hexdigest(id.to_s)
  end

  def sections
    @sections ||= [
      OpenStruct.new({
        name: 'Showcase',
        allow: %w(video text image),
        editable: true,
        index: 1,
        id: 'showcase',
        icon: 'fa-picture-o',
      }),
      OpenStruct.new({
        name: 'Hardware design',
        allow: %w(video text image parts),
        defaults: %w(parts schematics),
        editable: true,
        index: 2,
        id: 'hardware',
        icon: 'fa-gears',
      }),
      OpenStruct.new({
        name: 'Software design',
        allow: %w(video text image code),
        defaults: %w(code),
        editable: true,
        index: 3,
        id: 'software',
        icon: 'fa-code',
      }),
      # OpenStruct.new({
      #   name: 'Collaborate',
      #   allow: %w(),
      #   editable: false,
      #   index: 4,
      #   id: 'collaborate',
      # }),
    ]
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

  def post_new_tweet!
    prepend = "New project: "  # 13 characters
    message = to_tweet(prepend)
    TwitterQueue.perform_async 'update', message
  end

  def to_tweet prepend='', append=''
    # we have 118 characters to play with

    message = prepend

    message << name.gsub(/\.$/, '')

    if guest_name.present?
      message << " by #{guest_name}"
    else
      user = users.first
      if user
        message << " by #{user.name}"
        if link = user.twitter_link.presence and handle = link.match(/twitter.com\/([a-zA-Z0-9_]+)/).try(:[], 1)
          message << " (@#{handle})"
        end
      end
    end

    tags = teches.map do |tech|
      out = "##{tech.name.gsub(/\s+/, '')}"
      if link = tech.twitter_link.presence and handle = link.match(/twitter.com\/([a-zA-Z0-9_]+)/).try(:[], 1)
        out << " (@#{handle})"
      end
      out
    end
    message << " with #{tags.to_sentence}" if tags.any?

    size = message.size + 23
    message << " hackster.io/#{uri}"  # links are shortened to 22 characters

    # we add tags until character limit is reached
    tags = product_tags_cached.map{|t| "##{t.gsub(/[^a-zA-Z0-9]/, '')}"}
    if tags.any?
      tags.each do |tag|
        new_size = size + tag.size + 1
        if new_size <= 140
          message << " #{tag}"
          size += " #{tag}".size
        else
          break
        end
      end
    end
    # "#{message} (#{size})"
    message
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

  def website_host
    URI.parse(website).host.gsub(/^www\./, '')
  rescue
    website
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
      name.present? and description.present? and cover_image.try(:file_url).present?
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
      self.website = 'http://' + website if website_changed? and website.present? and !(website =~ /^http/)
      self.buy_link = 'http://' + buy_link if buy_link_changed? and buy_link.present? and !(buy_link =~ /^http/)
    end

    def external_is_hidden
      self.hide = true
    end

    def generate_slug
      slug = I18n.transliterate(name).gsub(/[^a-zA-Z0-9\-]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase
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

    def remove_whitespaces_from_html text
      text.gsub(/>\s{2,}/, "> ").gsub(/\s{2,}</, " <")
    end

    def set_columns_count
      self.columns_count = 1
    end

    def slug_is_unique
      return unless slug_changed?

      parent = team ? self.class.joins(:team).where(groups: { user_name: team.user_name }) : self.class
      errors.add :new_slug, 'has already been taken' if parent.where(projects: { slug: slug }).where.not(id: id).any?
    end

    def widgets_to_text
      output = ''
      # last_widget = widgets.last

      widgets.each do |widget|
        widget_content = widget.to_text
        if widget_content.present?
          output << widget.to_text
          # output << '<hr>' unless last_widget == widget
        end
      end

      output
    end
end
