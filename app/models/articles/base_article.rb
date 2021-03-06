class BaseArticle < ActiveRecord::Base

  self.table_name = :projects

  DEFAULT_NAME = 'Untitled'
  DIFFICULTIES = {
    'Easy' => :beginner,
    'Intermediate' => :intermediate,
    'Advanced' => :advanced,
    'Super hard' => :hardcore,
  }
  FILTERS = {
    '7days' => :last_7days,
    '30days' => :last_30days,
    '1year' => :last_1year,
    'featured' => :featured,
    'gfeatured' => :featured_by_collection,
    'me' => :for_user,
    'on_hackster' => :self_hosted,
    'toolbox' => :in_toolbox,
    'wip' => :wip,
  }
  PUBLISHED_STATES = %w(pending_review approved needs_work)
  SORTING = {
    'magic' => :magic_sort,
    'popular' => :most_popular,
    'recent' => :most_recent,
    'respected' => :most_respected,
    'trending' => :trending,
    'updated' => :last_updated,
  }
  TYPES = {
    'External (hosted on another site)' => 'ExternalProject',
    'Project' => 'Project',
  }
  MACHINE_TYPES = {
    'external' => 'ExternalProject',
    'normal' => 'Project',
  }

  include Checklist
  include EditableSlug
  include HstoreColumn
  include HstoreCounter
  include Privatable
  include Taggable
  include Workflow

  editable_slug :slug

  belongs_to :origin_platform, class_name: 'Platform'
  belongs_to :team, dependent: :destroy
  has_many :active_users, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'")}, through: :team_members, source: :user
  has_many :assignments, through: :project_collections, source: :collectable, source_type: 'Assignment'
  has_many :comments, -> { order created_at: :asc }, as: :commentable, dependent: :destroy
  # below is a hack because commenters try to add order by comments created_at and pgsql doesn't like it
  has_many :comments_copy, as: :commentable, dependent: :destroy, class_name: 'Comment'
  has_many :commenters, -> { uniq true }, through: :comments_copy, source: :user
  has_many :communities, -> { where("groups.type = 'Community'") }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :follow_relations, as: :followable
  has_many :grades, foreign_key: :project_id
  has_many :groups, -> { where(groups: { private: false }, project_collections: { workflow_state: ProjectCollection::VALID_STATES }) }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :impressions, dependent: :destroy, class_name: 'ProjectImpression', foreign_key: :project_id
  has_many :parts, through: :part_joins
  has_many :part_joins, -> { order(:position) }, as: :partable, dependent: :destroy do
    def hardware
      joins(:part).where(parts: { type: 'HardwarePart' })
    end
    def software
      joins(:part).where(parts: { type: 'SoftwarePart' })
    end
    def tool
      joins(:part).where(parts: { type: 'ToolPart' })
    end
  end
  has_many :part_platforms, -> { where("parts.exclude_from_platform = 'f'") }, through: :parts, source: :platform do
    # doesn't seem to want to work if we make the scope below default
    def default_scope
      reorder("groups.full_name ASC").uniq
    end
  end
  has_many :part_secondary_platforms, -> { where("parts.exclude_from_platform = 'f'") }, through: :parts, source: :platforms do
    # doesn't seem to want to work if we make the scope below default
    def default_scope
      reorder("groups.full_name ASC").uniq
    end
  end
  has_many :project_collections, dependent: :destroy, foreign_key: :project_id do
    def certified
      where "CAST(project_collections.properties -> 'certified' AS BOOLEAN) = ?", true
    end
  end
  has_many :visible_collections, -> { visible }, class_name: 'ProjectCollection', foreign_key: :project_id
  has_many :visible_platforms, -> { where("groups.type = 'Platform'") }, through: :visible_collections, source_type: 'Group', source: :collectable
  has_many :images, as: :attachable, dependent: :destroy
  has_many :lists, -> { where("groups.type = 'List'") }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :notifications, as: :notifiable, dependent: :delete_all
  has_many :permissions, as: :permissible
  has_many :reputation_events, as: :event_model, dependent: :delete_all
  has_many :respects, dependent: :destroy, as: :respectable
  has_many :respecting_users, -> { order 'respects.created_at ASC' }, through: :respects, source: :user
  has_many :slug_histories, -> { order updated_at: :desc }, as: :sluggable, dependent: :destroy
  has_many :sub_platforms, through: :parts, source: :child_platforms
  has_many :team_members, -> { order(created_at: :asc).where("members.approved_to_join <> 'f' OR members.approved_to_join IS NULL") }, through: :team, source: :members #.includes(:user)
  has_many :platforms, -> { where("groups.type = 'Platform'").order("groups.full_name ASC") }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :users, through: :team_members
  has_many :widgets, -> { order position: :asc }, as: :widgetable, dependent: :destroy
  has_one :cover_image, -> { order created_at: :desc }, as: :attachable, class_name: 'CoverImage', dependent: :destroy  # added order because otherwise it randomly picks up the wrong image
  has_one :project_collection, class_name: 'ProjectCollection'
  has_one :review_thread, foreign_key: :project_id, inverse_of: :project, dependent: :destroy

  sanitize_text :name
  register_sanitizer :sanitize_description, :before_validation, :description
  register_sanitizer :strip_tags, :before_save, :name
  register_sanitizer :remove_whitespaces_from_html, :before_save, :description
  attr_accessible :description, :name,
    :team_members_attributes, :website, :one_liner, :widgets_attributes,
    :featured, :featured_date, :cover_image_id, :license, :slug,
    :slug_histories_attributes,
    :graded, :guest_name,
    :hacker_space_id, :event_id, :assignment_id,
    :community_ids, :new_group_id,
    :team_attributes, :made_public_at, :difficulty, :type,
    :project_collections_attributes, :workflow_state, :part_joins_attributes,
    :locale, :discovery_settings
  attr_accessor :private_changed, :needs_platform_refresh, :approved_changed,
    :updater_id
  accepts_nested_attributes_for :images, :team_members,
    :widgets, :cover_image, :permissions, :slug_histories, :team,
    :project_collections, :part_joins, allow_destroy: true

  validates :name, length: { in: 3..60 }, allow_blank: true
  validates :one_liner, presence: true, if: proc { |p| p.force_basic_validation? }
  validates :one_liner, length: { maximum: 140 }
  validates :new_slug,
    format: { with: /\A[a-z0-9_\-]+\z/, message: "accepts only downcase letters, numbers, dashes '-' and underscores '_'." },
    length: { maximum: 105 }, allow_blank: true
  validates :new_slug, presence: true, if: proc{ |p| p.persisted? }
  # validates :website, uniqueness: { message: 'has already been submitted' }, allow_blank: true, if: proc {|p| p.website_changed? }
  validates :guest_name, length: { minimum: 3 }, allow_blank: true
  validates :duration, numericality: true, allow_blank: true
  validate :tags_length_is_valid, if: proc{|p| p.product_tags_string_changed? }
  validate :slug_is_unique
  before_validation :delete_empty_part_ids
  before_validation :clean_permissions
  before_validation :ensure_website_protocol
  before_create :generate_hid
  before_save :ensure_name
  before_create :generate_slug
  before_update :update_slug, if: proc {|p| p.name_changed? }
  after_update :mark_needs_review!, if: proc {|p| p.private_changed? and p.publyc? and p.can_mark_needs_review? }

  taggable :product_tags, :platform_tags

  counters_column :counters_cache, long_format: true
  has_counter :comments, 'comments.live.count'
  has_counter :communities, 'groups.count'
  has_counter :platforms, 'platforms.count'
  has_counter :platform_tags, 'platform_tags_cached.count'
  has_counter :product_tags, 'product_tags_cached.count'
  has_counter :real_respects, 'respects.joins(:user).where.not("users.email ILIKE \'%@user.hackster.io\'").count'
  has_counter :respects, 'respects.count', accessor: false
  has_counter :team_members, 'users.count'

  store :properties, accessors: []
  hstore_column :hproperties, :celery_id, :string
  hstore_column :hproperties, :challenge_id, :integer
  hstore_column :hproperties, :content_type, :string
  hstore_column :hproperties, :cost, :float
  hstore_column :hproperties, :desc_backup, :string
  hstore_column :hproperties, :duration, :float
  hstore_column :hproperties, :guest_twitter_handle, :string
  hstore_column :hproperties, :locked, :boolean
  hstore_column :hproperties, :platform, :string
  hstore_column :hproperties, :review_comment, :string
  hstore_column :hproperties, :review_time, :datetime
  hstore_column :hproperties, :reviewer_id, :string
  hstore_column :hproperties, :story_json, :json_object
  hstore_column :hproperties, :toc, :array, default: []
  hstore_column :hproperties, :tweeted_at, :datetime

  self.per_page = 21

  workflow do
    state :unpublished do
      event :publish, transitions_to: :pending_review
    end
    state :pending_review do
      event :approve, transitions_to: :approved
      event :reject, transitions_to: :rejected
      event :mark_needs_work, transitions_to: :needs_work
      event :unpublish, transitions_to: :unpublished
    end
    state :approved do
      event :reject, transitions_to: :rejected
      event :mark_needs_work, transitions_to: :needs_work
      event :mark_needs_review, transitions_to: :pending_review
    end
    state :rejected do
      event :approve, transitions_to: :approved
      event :mark_needs_work, transitions_to: :needs_work
      event :mark_needs_review, transitions_to: :pending_review
    end
    state :needs_work do
      event :approve, transitions_to: :approved
      event :reject, transitions_to: :rejected
      event :mark_needs_review, transitions_to: :pending_review
    end
    on_transition do |from, to, triggering_event, *event_args|
      if event_args[0]
        self.reviewer_id = event_args[0][:reviewer_id]
        self.review_comment = event_args[0][:review_comment]
        self.review_time = Time.now
        save
      end
    end
    after_transition do |from, to, triggering_event, *event_args|
      notify_observers(:after_workflow_update)
      notify_observers(:"after_#{to}")
    end
  end

  add_checklist :name, 'Name', 'name.present? and !has_default_name?'
  add_checklist :one_liner, 'Elevator pitch'
  add_checklist :cover_image, 'Cover image', 'cover_image and cover_image.file_url'
  add_checklist :difficulty, 'Skill level'
  add_checklist :product_tags_string, 'Tags'

  # beginning of search methods
  include AlgoliaSearchHelpers
  has_algolia_index 'unpublished?'

  def to_indexed_json
    elements = Sanitize::Config::RELAXED[:elements].dup
    elements.delete('img')
    sanitize_config = {remove_contents: %w(script style), elements: elements}
    _description = Sanitize.fragment(decorate.story_json(:normal, text_only: true), sanitize_config) || description
    _description = ActionController::Base.helpers.strip_tags(_description)[0..5000]

    {
      # for locating
      id: id,
      model: self.class.model_name.name,
      objectID: algolia_id,

      # for search
      authors: users.map{ |u|
        {
          id: u.id,
          name: u.name,
        }
      },
      content_type: content_type,
      description: _description,
      name: name,
      pitch: one_liner,
      parts: parts.map{|p|
        {
          id: p.id,
          mpn: p.mpn,
          name: p.name,
        }
      },
      platforms: visible_platforms.map{|p|
        {
          id: p.id,
          name: p.name,
        }
      },
      _tags: product_tags_cached,

      # for display
      cover_image_url: decorate(context: { current_site: nil }).cover_image(:cover_mini_thumb),
      url: UrlGenerator.new(path_prefix: nil, locale: nil).project_path(self),

      # for ranking
      comments_count: comments_count,
      impressions_count: impressions_count,
      made_public_at: made_public_at.to_i,
      popularity: popularity_counter,
      respects_count: respects_count,
    }
  end

  def self.index_all limit=nil
    algolia_batch_import indexable.includes(:cover_image, :users, :visible_platforms, :parts, :team), limit
  end
  # end of search methods

  def self.approved
    where(workflow_state: :approved)
  end

  def self.content_types classes=TYPES.values
    classes.inject({}){|mem, c| c.constantize::PUBLIC_CONTENT_TYPES.merge(mem) }
  end

  def self.need_review
    where(workflow_state: :pending_review)
  end

  def self.custom_for user
    col_projects = select('projects.id').joins("LEFT JOIN project_collections as pj1 ON pj1.project_id = projects.id").joins("LEFT JOIN follow_relations AS fr1 ON fr1.followable_id = pj1.collectable_id AND fr1.followable_type = pj1.collectable_type").where("fr1.user_id = ?", user.id).distinct("projects.id")
    user_projects = select('projects.id').joins("LEFT JOIN groups ON groups.id = projects.team_id").joins("LEFT JOIN members ON groups.id = members.group_id").joins("LEFT JOIN follow_relations AS fr2 ON fr2.followable_id = members.user_id AND fr2.followable_type = 'User'").where("fr2.user_id = ?", user.id).distinct("projects.id")
    part_projects = select('projects.id').joins("LEFT JOIN part_joins as pj2 ON pj2.partable_id = projects.id AND pj2.partable_type = 'BaseArticle'").joins("INNER JOIN parts ON pj2.part_id = parts.id").where.not(parts: { platform_id: nil, exclude_from_platform: true }).joins("LEFT JOIN follow_relations AS fr3 ON fr3.followable_id = pj2.part_id AND fr3.followable_type = 'Part'").where("fr3.user_id = ?", user.id).distinct("projects.id")

    where("projects.id IN (?) OR projects.id IN (?) OR projects.id IN (?)", col_projects, user_projects, part_projects).includes(:parts, :platforms, :project_collections, :users)
  end

  def self.external
    where(type: 'ExternalProject')
  end

  def self.featured opts={}
    indexable.where(featured: true).order(featured_date: :desc)
  end

  def self.featured_by_collection opts={}
    collectable_type, collectable_id = opts[:collectable_type], opts[:collectable_id]
    indexable_and_external.joins(:project_collections).where(project_collections: { collectable_id: collectable_id, collectable_type: collectable_type, workflow_state: 'featured' }).order('project_collections.updated_at DESC')
    # where(project_collections: { workflow_state: 'featured' })
  end

  def self.for_thumb_display
    includes(:users).includes(:cover_image).includes(:team)
  end

  def self.for_thumb_display_in_collection
    includes(project: :users).includes(project: :cover_image).includes(project: :team)
  end

  def self.for_user opts={}
    user = opts[:user]
    user ? custom_for(user) : where('1=0')  # returns an AR relation
  end

  def self.guest
    where("projects.guest_name <> '' AND projects.guest_name IS NOT NULL")
  end

  def self.indexable
    live.approved.where("projects.featured_date < ?", Time.now)
  end

  def self.indexable_and_external
    where("(projects.workflow_state = 'approved' AND projects.private = 'f') OR (projects.type = 'ExternalProject' AND projects.workflow_state <> 'rejected')")#.magic_sort
  end

  def self.in_toolbox opts={}
    user = opts[:user]
    indexable.joins(:parts).where.not(parts: { platform_id: nil }).joins("LEFT JOIN follow_relations AS fr ON fr.followable_id = parts.id AND fr.followable_type = 'Part'").where("fr.user_id = ?", user.id)#.distinct('projects.id')  # doesn't work with project_collections.merge :/
  end

  def self.live
    publyc
  end

  def self.last_7days opts={}
    last_n 7.days, opts
  end

  def self.last_30days opts={}
    last_n 30.days, opts
  end

  def self.last_1year opts={}
    last_n 1.year, opts
  end

  def self.last_n n, opts={}
    column = opts[:show_all] ? 'made_public_at' : 'featured_date'
    where("projects.#{column} > ?", n.ago)
  end


  def self.last_created opts={}
    order(created_at: :desc)
  end

  def self.last_featured opts={}
    order featured_date: :desc
  end

  def self.last_published opts={}
    order made_public_at: :desc
  end

  def self.last_updated opts={}
    order(updated_at: :desc)
  end


  def self.median_impressions
    indexable.median(:impressions_count)
  end

  def self.median_respects
    indexable.median(:respects_count)
  end

  def self.most_popular opts={}
    order(impressions_count: :desc)
  end

  def self.most_recent opts={}
    opts[:show_all] ? last_published : last_featured
  end

  def self.most_respected opts={}
    order(respects_count: :desc)
  end

  def self.own
    where("projects.guest_name = '' OR projects.guest_name IS NULL")
  end

  def self.pending_review
    where workflow_state: :pending_review
  end

  def self.published
    publyc.where workflow_state: PUBLISHED_STATES
  end

  def self.scheduled_to_be_approved
    approved.where("projects.featured_date > ?", Time.now).order(:featured_date)
  end

  def self.self_hosted opts={}
    where(type: 'Project')
  end

  def self.trending opts={}
    order(popularity_counter: :desc, created_at: :desc)
  end

  class << self; alias_method :magic_sort, :trending; end

  def self.unpublished
    where workflow_state: :unpublished
  end

  def self.visible
    joins(:project_collections).where(project_collections: { workflow_state: ProjectCollection::VALID_STATES })
  end

  def self.wip opts={}
    indexable.with_type('wip').last_updated
  end

  def self.with_group group, opts={}
    records = joins(:project_collections).where(project_collections: { collectable_id: group.id, collectable_type: 'Group' })
    records = records.where(project_collections: { workflow_state: ProjectCollection::VALID_STATES }) unless opts[:all_moderation_states] == true
    records
  end

  def self.with_origin_platform group
    where(origin_platform_id: group.id)
  end

  def self.with_type content_type
    where "projects.hproperties @> hstore('content_type', ?)", content_type
  end

  def approve_later! *args
    next_time_slot = get_next_time_slot BaseArticle.scheduled_to_be_approved.last.try(:featured_date)
    update_column :featured_date, next_time_slot
    approve! *args
  end

  def certifier_names
    Rails.cache.fetch ["project-#{id}-certified"], tag: ["project-#{id}-certified"] do
      project_collections.certified.joins("INNER JOIN groups ON project_collections.collectable_id = groups.id AND project_collections.collectable_type = 'Group'").pluck("groups.full_name").sort
    end
  end

  def content_type_to_human
    @content_type_to_human ||= self.class::CONTENT_TYPES_TO_HUMAN[content_type.try(:to_sym)]
  end

  def credit_lines
    @credit_lines ||= credits_widget.try(:credit_lines) || []
  end

  def credits_widget
    @credits_widget ||= CreditsWidget.where(widgetable_id: id, widgetable_type: 'BaseArticle').first_or_create
  end

  def extract_toc!
    toc = if story_json.present?
      story_json.select{|i| i['type'] == 'CE' }.map{|i| i['json'].select{|j| j['tag'] == 'h3' }.map{|j| extract_content_from_story_json(j) } }
    elsif description.present?
      doc = Nokogiri::HTML::DocumentFragment.parse description
      doc.css('h3').map{|h| h.text }
    else
      []
    end
    self.toc = toc.flatten.map{|v| v.try(:gsub, /[^a-zA-Z0-9]$/, '').try(:strip) }.select{|v| v.present? }
  end

  def get_next_time_slot last_scheduled_slot
    last_scheduled_slot ||= Time.now
    days = ((last_scheduled_slot - Time.now) / SECONDS_IN_A_DAY).round
    per_day = 2 + days
    hour_interval = 24.to_f / per_day
    minute_interval = hour_interval * 60
    last_scheduled_slot + minute_interval.minutes
  end

  def scheduled_to_be_approved?
    approved? and featured_date > Time.now
  end

  def age
    (Time.now - (made_public_at || created_at)) / SECONDS_IN_A_DAY
  end

  # highly unoptimized, use cautiously
  def all_platforms
    (Platform.joins(:platform_tags).references(:tags).where("LOWER(tags.name) IN (?)", platform_tags_cached.map{|t| t.downcase }).uniq + part_platforms.default_scope + part_secondary_platforms.default_scope).uniq
  end

  def cover_image_id=(val)
    attribute_will_change! :cover_image
    self.cover_image = CoverImage.find_by_id(val)
  end

  def disable_tweeting?
    assignment.present?
  end

  def discovery_settings
    if pryvate
      'private'
    elsif workflow_state == 'unpublished'
      'unpublished'
    else
      'published'
    end
  end

  def discovery_settings=(val)
    case val
    when 'private'
      self.pryvate = true
      self.workflow_state = 'unpublished'
    when 'unpublished'
      self.pryvate = false
      self.workflow_state = 'unpublished'
    when 'published'
      self.pryvate = false
      if workflow_state == 'unpublished'
        self.workflow_state = 'pending_review'
      end
    end
  end

  def external
    external?
  end

  def external=(val)
    self.type = 'ExternalProject' if val
  end

  def external?
    type == 'ExternalProject'
  end

  def identifier
    'base_article'
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

  def known_platforms
    Platform.includes(:platform_tags).references(:tags).where("LOWER(tags.name) IN (?)", platform_tags_cached.map{|t| t.downcase })
  end

  def has_default_name?
    name == DEFAULT_NAME
  end

  def has_part_related_to_origin_platform?
    parts.where(platform_id: origin_platform_id, exclude_from_platform: false).exists?
  end

  def has_platform?
    !origin_platform_id.zero?
  end

  def hidden?
    hide
  end

  def image
    images.first
  end

  def is_protip?
    content_type.in? %w(protip getting_started teardown)
  end

  def is_tutorial?
    content_type == 'tutorial'
  end

  def is_wip?
    content_type == 'wip'
  end

  def languages
    widgets.where(type: %w(CodeWidget)).map(&:language).uniq - ['text']
  end

  def license
    return @license if @license
    val = read_attribute(:license)
    @license = License.new(val) if val.present?
  end

  # def name
  #   super.presence ||(persisted? ? DEFAULT_NAME : nil)
  # end

  def new_group_id=(val)
    project_collections.new collectable_type: 'Group', collectable_id: val
  end

  def needs_review?
    publyc? and (pending_review? or needs_work?)
  end

  def origin_site
    @origin_site ||= ClientSubdomain.joins(:platform).where(groups: { id: origin_platform_id }).first if has_platform?
  end

  def security_token
    Digest::MD5.hexdigest(id.to_s)
  end

  def slug_was_changed?
    @old_slug.present? and @old_slug != slug
  end

  # def to_param
  #   [slug, hid].join('-')
  # end

  def to_tracker
    {
      comments_count: comments_count,
      is_public: publyc?,
      project_id: id,
      project_name: name,
      product_tags_count: product_tags_count,
      respects_count: respects_count,
      views_count: impressions_count,
      content_type: content_type,
    }
  end

  def post_tweet!
    message = prepare_tweet
    media_url = cover_image.try(:imgix_url, :medium)
    Tweeter.new(message).update

    update_attribute :tweeted_at, Time.now
  end

  def schedule_tweet! time=nil
    if time
      TwitterQueue.perform_at time, 'post_project_tweet', id
    else
      TwitterQueue.perform_async 'throttle_project_tweet', id
    end
  end

  def prepare_tweet opts={}
    opts[:prepend] = "🆕 "  # 2 characters
    TweetBuilder.new(self).tweet(opts)
  end

  def product_tags_string_changed?
    (product_tags_string_was || '').split(',').map{|t| t.strip } != (product_tags_string || '').split(',').map{|t| t.strip }
  end

  def slug_hid
    [slug, hid].join('-')
  end

  def should_tweet?
    !hidden? and tweeted_at.nil?
  end

  def to_js opts={}
    protocol = APP_CONFIG['use_ssl'] ? 'https' : 'http'
    subdomain = opts[:subdomain].presence || ENV['SUBDOMAIN']
    domain = APP_CONFIG['default_domain']
    domain += ':' + APP_CONFIG['default_port'].to_s if APP_CONFIG['port_required']
    host = subdomain + '.' + domain
    base_url = "#{protocol}://#{host}"
    url = base_url + "/#{uri}"
    url += "?auth_token=#{security_token}" if opts[:private_url]
    {
      author: {
        name: users.first.try(:name),
        url: base_url + "/#{users.first.try(:user_name)}",
      },
      name: name,
      one_liner: one_liner,
      url: url,
      cover_image_url: cover_image.try(:imgix_url, :cover_thumb),
      views_count: impressions_count,
      respects_count: respects_count,
      comments_count: comments_count,
    }
  end

  def unlisted?
    publyc? and unpublished?
  end

  def update_slug
    generate_slug unless slug_was_changed?
  end

  def update_slug!
    update_slug
    save validate: false
  end

  def uri user_name=user_name_for_url
    "#{user_name}/#{slug_hid}"
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

  %w(assignment).each do |type|
    define_method type do
      get_collection type
    end

    define_method "#{type}=" do |val|
      set_collection val, type
    end

    define_method "#{type}_id" do
      get_collection_id type
    end

    define_method "#{type}_id=" do |val|
      set_collection_id val, type
    end
  end

  private
    def can_be_public?
      name.present? and description.present? and cover_image.try(:file_url).present?
    end

    def clean_permissions
      permissions.each do |permission|
        permissions.delete(permission) if permission.new_record? and permission.grantee.nil?
      end
    end

    def delete_empty_part_ids
      (part_joins).each do |part_join|
        part_join.delete if part_join.part_id.blank?
      end
    end

    def ensure_name
      self.name = DEFAULT_NAME unless name.present?
    end

    def ensure_website_protocol
      self.website = 'http://' + website if website_changed? and website.present? and !(website =~ /^http/)
    end

    def extract_content_from_story_json item
      return item['content'] if item['content'].present?

      item['children'].map do |child|
        extract_content_from_story_json(child)
      end.join(' ')
    end

    def generate_slug
      return 'untitled' if name.blank?

      self.slug = I18n.transliterate(name).gsub(/[^a-zA-Z0-9\-]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase.presence || 'untitled'
    end

    def generate_hid
      exists = true
      while exists
        hid = SecureRandom.hex(3)
        exists = BaseArticle.exists?(hid: hid)
      end
      self.hid = hid
    end

    def remove_whitespaces_from_html text
      text.gsub(/>\s{2,}/, "> ").gsub(/\s{2,}</, " <")
    end

    def slug_is_unique
      return unless slug_changed?

      parent = team ? self.class.joins(:team).where(groups: { user_name: team.user_name }) : self.class
      errors.add :new_slug, 'has already been taken' if parent.where("LOWER(projects.slug) = ?", slug.downcase).where.not(id: id).any?
    end

    def strip_tags text
      text = ActionController::Base.helpers.strip_tags(text)

      # so that these characters don't show escaped. Not the cleanest...
      {
        '&amp;' => '&',
        '&lt;' => '<',
        '&gt;' => '>',
        '&quot;' => '"',
      }.each do |code, character|
        text.gsub! Regexp.new(code), character
      end
      text
    end

    def sanitize_description text
      if text
        doc = Nokogiri::HTML::DocumentFragment.parse(text)

        {
          'strong' => 'b',
          'h1' => 'h2',
          'em' => 'i',
        }.each do |orig_tag, proper_tag|
          doc.css(orig_tag).each{|el| el.name = proper_tag }
        end

        Sanitize.clean(doc.to_s.encode("UTF-8"), Sanitize::Config::SCRAPER)
      end
    end

    def tags_length_is_valid
      errors.add :product_tags_array, 'too many tags (3 max, choose wisely!)' if product_tags_array.length > 3
    end

    # the following methods make has_many relations work has_one style
    def get_collection collection_type
      send("#{collection_type}s").first
    end

    def get_collection_id collection_type
      get_collection(collection_type).try(:id)
    end

    def set_collection_id id, collection_type
      self.send("#{collection_type}s").destroy_all
      self.send("#{collection_type}s") << collection_type.camelize.constantize.find_by_id(id) if id.to_i != 0
    end

    def set_collection collection, collection_type
      self.send("#{collection_type}s").destroy_all
      self.send("#{collection_type}s") << collection if collection
    end
end
