class Project < ActiveRecord::Base
  DEFAULT_NAME = 'Untitled'

  DIFFICULTIES = {
    'Beginner' => :beginner,
    'Intermediate' => :intermediate,
    'Advanced' => :advanced,
    'Hardcore hacker' => :hardcore,
  }

  FILTERS = {
    '7days' => :last_7days,
    '30days' => :last_30days,
    'featured' => :featured,
    'gfeatured' => :featured_by_collection,
    'on_hackster' => :self_hosted,
    'wip' => :wip,
  }
  SORTING = {
    'magic' => :magic_sort,
    'popular' => :most_popular,
    'recent' => :last_public,
    'respected' => :most_respected,
    'trending' => :magic_sort,
    'updated' => :last_updated,
  }
  TYPES = {
    'External (hosted on another site)' => 'ExternalProject',
    'Normal' => 'Project',
    'Product' => 'Product',
  }

  include Counter
  include EditableSlug
  include Privatable
  include StringParser
  include Taggable
  # include Workflow

  editable_slug :slug

  is_impressionable counter_cache: true, unique: :session_hash

  belongs_to :team
  has_many :active_users, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'")}, through: :team_members, source: :user
  has_many :assignments, through: :project_collections, source: :collectable, source_type: 'Assignment'
  has_many :awards
  has_many :build_logs, as: :threadable, dependent: :destroy
  has_many :challenge_entries
  has_many :comments, -> { order created_at: :asc }, as: :commentable, dependent: :destroy
  # below is a hack because commenters try to add order by comments created_at and pgsql doesn't like it
  has_many :comments_copy, as: :commentable, dependent: :destroy, class_name: 'Comment'
  has_many :commenters, -> { uniq true }, through: :comments_copy, source: :user
  has_many :communities, -> { where("groups.type = 'Community'") }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :events, -> { where("groups.type = 'Event'") }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :follow_relations, as: :followable
  has_many :followers, through: :follow_relations, source: :user
  has_many :grades
  has_many :hacker_spaces, -> { where("groups.type = 'HackerSpace'") }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :parts, through: :parts_widgets
  has_many :parts_widgets, as: :widgetable
  has_many :project_collections, dependent: :destroy
  has_many :visible_collections, -> { visible }, class_name: 'ProjectCollection'
  has_many :visible_platforms, -> { where("groups.type = 'Platform'") }, through: :visible_collections, source_type: 'Group', source: :collectable
  has_many :issues, as: :threadable, dependent: :destroy
  has_many :images, as: :attachable, dependent: :destroy
  has_many :lists, -> { where("groups.type = 'List'") }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :permissions, as: :permissible
  has_many :project_collections, dependent: :destroy
  has_many :respects, dependent: :destroy, as: :respectable
  has_many :respecting_users, -> { order 'respects.created_at ASC' }, through: :respects, source: :user
  has_many :slug_histories, -> { order updated_at: :desc }, as: :sluggable, dependent: :destroy
  has_many :team_members, -> { order(created_at: :asc).where("members.approved_to_join <> 'f' OR members.approved_to_join IS NULL") }, through: :team, source: :members #.includes(:user)
  has_many :platforms, -> { where("groups.type = 'Platform'") }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :users, through: :team_members
  has_many :widgets, -> { order position: :asc }, as: :widgetable, dependent: :destroy
  has_one :cover_image, -> { order created_at: :desc }, as: :attachable, class_name: 'CoverImage', dependent: :destroy  # added order because otherwise it randomly picks up the wrong image
  has_one :logo, as: :attachable, class_name: 'Avatar', dependent: :destroy
  has_one :project_collection, class_name: 'ProjectCollection'
  has_one :video, as: :recordable, dependent: :destroy

  # sanitize_text :description
  register_sanitizer :remove_whitespaces_from_html, :before_save, :description
  attr_accessible :description, :end_date, :name, :start_date, :current,
    :team_members_attributes, :website, :one_liner, :widgets_attributes,
    :featured, :featured_date, :cover_image_id, :logo_id, :license, :slug,
    :permissions_attributes, :slug_histories_attributes, :hide,
    :graded, :wip, :columns_count, :external, :guest_name,
    :approved, :open_source, :buy_link, :private_logs, :private_issues,
    :hacker_space_id, :locked, :mark_as_idea, :event_id, :assignment_id,
    :community_ids, :new_group_id, :guest_twitter_handle, :celery_id,
    :team_attributes, :story, :made_public_at, :difficulty, :type, :product
  attr_accessor :current, :private_changed, :needs_platform_refresh,
    :approved_changed
  accepts_nested_attributes_for :images, :video, :logo, :team_members,
    :widgets, :cover_image, :permissions, :slug_histories, :team,
    allow_destroy: true

  validates :name, length: { in: 3..60 }, allow_blank: true
  validates :one_liner, :logo, presence: true, if: proc { |p| p.force_basic_validation? }
  validates :one_liner, length: { maximum: 140 }
  validates :new_slug,
    format: { with: /\A[a-z0-9_\-]+\z/, message: "accepts only downcase letters, numbers, dashes '-' and underscores '_'." },
    length: { maximum: 105 }, allow_blank: true
  validates :new_slug, presence: true, if: proc{ |p| p.persisted? }
  # validates :website, uniqueness: { message: 'has already been submitted' }, allow_blank: true, if: proc {|p| p.website_changed? }
  validates :guest_name, length: { minimum: 3 }, allow_blank: true
  validate :tags_length_is_valid
  validate :slug_is_unique
  # before_validation :check_if_current
  before_validation :clean_permissions
  before_validation :ensure_website_protocol
  before_update :update_slug, if: proc{|p| p.name_was == DEFAULT_NAME and p.name_changed? }
  # before_create :set_columns_count
  before_save :generate_slug, if: proc {|p| !p.persisted? or p.team_id_changed? }

  taggable :product_tags, :platform_tags

  store :counters_cache, accessors: [:comments_count, :product_tags_count,
    :widgets_count, :followers_count, :build_logs_count,
    :issues_count, :team_members_count, :platform_tags_count, :communities_count]

  store :properties, accessors: [:private_logs, :private_issues, :locked,
    :guest_twitter_handle, :celery_id]

  parse_as_integers :counters_cache, :comments_count, :product_tags_count,
    :widgets_count, :followers_count, :build_logs_count,
    :issues_count, :team_members_count, :platform_tags_count,
    :communities_count

  parse_as_booleans :properties, :private_logs, :private_issues, :locked

  self.per_page = 18

  # worlfow do
  #   state :idea
  #   state :prototype
  #   state :finished_product
  # end

  # beginning of search methods
  include TireInitialization
  has_tire_index 'private or hide or !approved'

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 100
      indexes :product_tags,    analyzer: 'snowball', boost: 50
      indexes :platform_tags,   analyzer: 'snowball', boost: 50
      indexes :platform_ids
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
      platform_tags: platform_tags_string,
      platform_ids: visible_platforms.pluck(:id),
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

  def self.custom_for user
    # indexable.joins("LEFT JOIN project_collections as pj1 ON pj1.project_id = projects.id").joins("LEFT JOIN follow_relations AS fr1 ON fr1.followable_id = pj1.collectable_id AND fr1.followable_type = pj1.collectable_type").joins("LEFT JOIN groups ON groups.id = projects.team_id").joins("LEFT JOIN members ON groups.id = members.group_id").joins("LEFT JOIN follow_relations AS fr2 ON fr2.followable_id = members.user_id AND fr2.followable_type = 'User'").where("fr1.user_id = ? OR fr2.user_id = ?", user.id, user.id).distinct("projects.id").last_public.includes(:project_collections)

    indexable.where("projects.id IN (?) OR projects.id IN (?)", select('projects.id').joins("LEFT JOIN project_collections as pj1 ON pj1.project_id = projects.id").joins("LEFT JOIN follow_relations AS fr1 ON fr1.followable_id = pj1.collectable_id AND fr1.followable_type = pj1.collectable_type").where("fr1.user_id = ?", user.id).distinct("projects.id"), select('projects.id').joins("LEFT JOIN groups ON groups.id = projects.team_id").joins("LEFT JOIN members ON groups.id = members.group_id").joins("LEFT JOIN follow_relations AS fr2 ON fr2.followable_id = members.user_id AND fr2.followable_type = 'User'").where("fr2.user_id = ?", user.id).distinct("projects.id")).last_public.includes(:project_collections).includes(:users)
  end

  def self.external
    where(type: 'ExternalProject')
  end

  def self.featured
    indexable.where(featured: true).order(featured_date: :desc)
  end

  def self.featured_by_collection collectable_type, collectable_id
    indexable_and_external.joins(:project_collections).where(project_collections: { collectable_id: collectable_id, collectable_type: collectable_type, workflow_state: 'featured' }).order('project_collections.updated_at DESC')
    # where(project_collections: { workflow_state: 'featured' })
  end

  def self.for_thumb_display
    includes(:users).includes(:cover_image).includes(:team)
  end

  def self.for_thumb_display_in_collection
    includes(project: :users).includes(project: :cover_image).includes(project: :team)
  end

  def self.indexable
    live.where(approved: true, hide: false).where("projects.made_public_at < ?", Time.now)
  end

  def self.indexable_and_external
    where("(projects.approved = 't' AND projects.private = 'f' AND projects.hide = 'f') OR (projects.type = 'ExternalProject' AND projects.approved <> 'f')")#.magic_sort
  end

  def self.live
    where(private: false)
  end

  def self.last_7days
    where('projects.made_public_at > ?', 7.days.ago)
  end

  def self.last_30days
    where('projects.made_public_at > ?', 30.days.ago)
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

  def self.own
    where("projects.guest_name = '' OR projects.guest_name IS NULL")
  end

  def self.products
    where(type: 'Product')
  end

  def self.self_hosted
    where(type: 'Project')
  end

  def self.wip
    indexable.where(wip: true).last_updated
  end

  def self.with_group group
    joins(:project_collections).where(project_collections: { collectable_id: group.id, collectable_type: 'Group' })
  end

  def age
    (Time.now - created_at) / 86400
  end

  def all_issues
    (issues + Issue.where(threadable_type: 'Widget').where('threadable_id IN (?)', widgets.pluck('widgets.id'))).sort_by{ |t| t.created_at }
  end

  def buy_link_host
    URI.parse(buy_link).host.gsub(/^www\./, '')
  rescue
    buy_link
  end

  def checklist
    {
      name: {
        label: 'Name',
        condition: 'name.present? and !has_default_name?',
      },
      one_liner: {
        label: 'Elevator pitch',
      },
      cover_image: {
        label: 'Cover image',
        condition: 'cover_image and cover_image.file_url'
      },
      difficulty: {
        label: 'Skill level',
      },
      product_tags_string: {
        label: 'Tags',
      },
      platform_tags_string: {
        label: 'Platforms used',
      },
      description: {
        label: 'Story',
      },
      parts: {
        label: 'Components',
        conditions: 'parts.any?',
      },
      schematics: {
        label: 'Schematics',
        condition: 'widgets.where(type: %w(SchematicRepoWidget SchematicFileWidget)).any?',
      },
      code: {
        label: 'Code',
        condition: 'widgets.where(type: %w(CodeWidget CodeRepoWidget)).any?',
      }
    }
  end

  def checklist_evaled
    return @checklist_evaled if @checklist_evaled

    done = []
    todo = []
    checklist.each do |name, item|
      item[:goto] = name

      condition = if item[:condition]
        item[:condition]
      else
        "#{name}.present?"
      end

      if eval(condition)
        done << item
      else
        todo << item
      end
    end

    @checklist_evaled = { done: done, todo: todo, complete: todo.empty? }
  end

  def compute_popularity time_period=365
    self.popularity_counter = ((respects_count * 4 + impressions_count * 0.05 + comments_count * 2 + featured.to_i * 10) * [1 - [(Math.log(age, time_period)), 1].min, 0.001].max).round(4)
  end

  def counters
    {
      build_logs: 'build_logs.published.count',
      comments: 'comments.count',
      communities: 'platforms.count',
      followers: 'followers.count',
      issues: 'issues.where(type: "Issue").count',
      product_tags: 'product_tags_cached.count',
      respects: 'respects.count',
      team_members: 'users.count',
      platform_tags: 'platform_tags_cached.count',
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

  def external
    external?
  end

  def external=(val)
    self.type = 'ExternalProject' if val
  end

  def external?
    type == 'ExternalProject'
  end

  def product
    product?
  end

  def product=(val)
    self.type = 'Product' if val
  end

  def product?
    type == 'Product'
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

  # the following methods make has_many relations work has_one style
  def get_collection collection_type
    send("#{collection_type}s").first
  end

  def get_collection_id collection_type
    get_collection(collection_type).try(:id)
  end

  def set_collection_id id, collection_type
    self.send("#{collection_type}s").delete_all
    self.send("#{collection_type}s") << collection_type.camelize.constantize.find_by_id(id) if id.to_i != 0
  end

  def set_collection collection, collection_type
    self.send("#{collection_type}s").delete_all
    self.send("#{collection_type}s") << collection if collection
  end

  %w(assignment event hacker_space).each do |type|
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

  def known_platforms
    Platform.includes(:platform_tags).references(:tags).where("LOWER(tags.name) IN (?)", platform_tags_cached.map{|t| t.downcase })
  end

  def has_assignment?
    assignment.present?
  end

  def has_no_assignment?
    assignment.nil?
  end

  def has_default_name?
    name == DEFAULT_NAME
  end

  def hidden?
    hide
  end

  def is_idea?
    workflow_state == 'idea'
  end

  def image
    images.first
  end

  def license
    return @license if @license
    val = read_attribute(:license)
    @license = License.new val if val.present?
  end

  def locked?
    locked
  end

  def logo_id=(val)
    self.logo = Avatar.find_by_id(val)
  end

  def mark_as_idea
    is_idea?
  end

  def mark_as_idea=(val)
    self.workflow_state = (val.in?([1, '1', 't']) ? 'idea' : nil)
  end

  def name
    super.presence ||(persisted? ? DEFAULT_NAME : nil)
  end

  def new_group_id=(val)
    project_collections.new collectable_type: 'Group', collectable_id: val
  end

  def security_token
    Digest::MD5.hexdigest(id.to_s)
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
      external: external?,
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
    message = prepare_tweet
    TwitterQueue.perform_async 'throttle_update', message
  end

  def post_new_tweet_at! time
    message = prepare_tweet
    TwitterQueue.perform_at time, 'update', message
  end

  def prepare_tweet
    prepend = "New project#{' idea' if is_idea?}: "  # 13-18 characters
    to_tweet(prepend)
  end

  def to_js
    {
      author: {
        name: users.first.try(:name),
        url: "#{APP_CONFIG['full_host']}/#{users.first.try(:user_name)}",
      },
      name: name,
      one_liner: one_liner,
      url: "#{APP_CONFIG['full_host']}/#{uri}",
      cover_image_url: cover_image.try(:file_url, :cover_thumb),
      views_count: impressions_count,
      respects_count: respects_count,
      comments_count: comments_count,
    }
  end

  def to_tweet prepend='', append=''
    # we have 113-118 characters to play with

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

    tags = platforms.map do |platform|
      out = platform.hashtag.presence || platform.default_hashtag
      if link = platform.twitter_link.presence and handle = link.match(/twitter.com\/([a-zA-Z0-9_]+)/).try(:[], 1)
        out << " (@#{handle})"
      end
      out
    end
    message << " with #{tags.to_sentence}" if tags.any?

    size = message.size + (is_idea? ? 28 : 23)
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

  def unlocked?
    !locked?
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
      errors.add :new_slug, 'has already been taken' if parent.where("LOWER(projects.slug) = ?", slug.downcase).where.not(id: id).any?
    end

    def tags_length_is_valid
      errors.add :product_tags_array, 'too many tags (20 max, choose wisely!)' if product_tags_array.length > 20
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
