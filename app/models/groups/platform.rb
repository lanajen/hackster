class Platform < List
  include Taggable

  MINIMUM_FOLLOWERS = 5
  MINIMUM_FOLLOWERS_STRICT = 25
  MODERATION_LEVELS = {
    'Approve all automatically' => 'auto',
    'Only projects approved by the Hackster team' => 'hackster',
    'Only projects approved by our team' => 'manual',
  }
  PARTS_TEXT_OPTIONS = ['"#{name} products"', '"Products made by #{name}"']
  PLANS = %w(starter professional)
  PROJECT_IDEAS_PHRASING = ['"No #{name} yet?"', '"Have ideas on what to build with #{name}?"']

  has_many :active_members, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'") }, foreign_key: :group_id, class_name: 'PlatformMember'
  has_many :announcements, as: :threadable, dependent: :destroy
  has_many :challenges
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'PlatformMember'
  has_many :parts

  has_many :part_projects, through: :parts, class_name: 'Project', source: :projects
  has_many :sub_parts, through: :parts, class_name: 'Part', source: :parent_parts
  has_many :sub_parts_projects, through: :parts, class_name: 'Project', source: :parent_projects
  has_many :sub_platforms, -> { uniq }, through: :sub_parts, class_name: 'Platform', source: :platform

  has_many :projects, -> { where(type: %w(Project ExternalProject)) }, through: :project_collections do
    # TOOD: see if this can be delegated to ProjectCollection
    def visible
      where(project_collections: { workflow_state: ProjectCollection::VALID_STATES })
    end
  end
  has_many :products, -> { products }, source: :project, through: :project_collections do
    # TOOD: see if this can be delegated to ProjectCollection
    def visible
      where(project_collections: { workflow_state: ProjectCollection::VALID_STATES })
    end
  end
  has_one :client_subdomain
  has_one :company_logo, as: :attachable, dependent: :destroy
  has_one :logo, as: :attachable, dependent: :destroy
  has_one :slug, as: :sluggable, dependent: :destroy, class_name: 'SlugHistory'

  attr_accessible :cover_image_id, :client_subdomain_attributes, :logo_id,
    :company_logo_id, :parts_attributes, :reset_api_credentials,
    :reset_portal_credentials

  attr_accessor :reset_api_credentials, :reset_portal_credentials

  accepts_nested_attributes_for :client_subdomain, :parts

  # before_save :update_user_name
  before_save :ensure_api_credentials,
    :ensure_portal_credentials,
    :ensure_platform_tags,
    :format_hashtag

  add_websites :forums, :documentation, :crowdfunding, :buy, :shoplocket,
    :download, :cta

  hstore_column :hproperties, :accept_project_ideas, :boolean
  hstore_column :hproperties, :active_challenge, :boolean
  hstore_column :hproperties, :api_password, :string
  hstore_column :hproperties, :api_username, :string
  hstore_column :hproperties, :cta_text, :string, default: "Buy %{h.indefinite_articlerize(name)}"
  hstore_column :hproperties, :description, :string
  hstore_column :hproperties, :disclaimer, :string
  hstore_column :hproperties, :enable_chat, :boolean
  hstore_column :hproperties, :enable_parts, :boolean
  hstore_column :hproperties, :enable_password, :boolean
  hstore_column :hproperties, :enable_products, :boolean
  hstore_column :hproperties, :enable_sub_parts, :boolean
  hstore_column :hproperties, :hidden, :boolean, default: true
  hstore_column :hproperties, :http_password, :string
  hstore_column :hproperties, :moderation_level, :string, default: 'hackster'
  hstore_column :hproperties, :plan, :string, default: 'starter'
  hstore_column :hproperties, :parts_text, :string, default: '%{parts_text_options.first}'
  hstore_column :hproperties, :products_text, :string, default: 'Startups powered by %{name}'
  hstore_column :hproperties, :project_ideas_phrasing, :string, default: '%{project_ideas_phrasing_options[0]}'
  hstore_column :hproperties, :verified, :boolean, default: false

  has_counter :external_projects, 'projects.external.count'
  has_counter :private_projects, 'projects.private.count'
  has_counter :parts, 'parts.count'
  has_counter :products, 'products.count'
  has_counter :projects, 'projects.visible.count'
  has_counter :sub_parts, 'sub_parts.count'
  has_counter :sub_platforms, 'sub_platforms.count'

  taggable :platform_tags, :product_tags

  is_impressionable counter_cache: true, unique: :session_hash

  # beginning of search methods
  has_tire_index 'private'

  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 1000
      indexes :platform_tags,       analyzer: 'snowball', boost: 500
      indexes :mini_resume,     analyzer: 'snowball', boost: 100
      indexes :created_at
    end
  end

  def to_indexed_json
    {
      _id: id,
      name: name,
      model: self.class.name.underscore,
      mini_resume: mini_resume,
      platform_tags: platform_tags_string,
      created_at: created_at,
      popularity: 1000.0,
    }.to_json
  end

  def self.index_all
    index.import public
  end
  # end of search methods

  def self.for_thumb_display
    includes(:avatar).includes(:cover_image)
  end

  def self.minimum_followers
    where("CAST(groups.hcounters_cache -> 'members' AS INTEGER) > ?", MINIMUM_FOLLOWERS)
  end

  def self.minimum_followers_strict
    where("CAST(groups.hcounters_cache -> 'members' AS INTEGER) > ?", MINIMUM_FOLLOWERS_STRICT)
  end

  def company_logo_id=(val)
    self.company_logo = CompanyLogo.find_by_id(val)
  end

  def generate_user_name
    return if full_name.blank?

    slug = name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase

    # make sure it doesn't exist
    if result = SlugHistory.where(value: slug).first
      return if self == result
      # if it exists add a 1 and increment it if necessary
      slug += '1'
      while SlugHistory.where(value: slug).first
        slug.succ!
      end
    end
    self.user_name = slug
  end

  def parts_text_options
    PARTS_TEXT_OPTIONS.map{|t| eval(t) }
  end

  def project_ideas_phrasing_options
    PROJECT_IDEAS_PHRASING.map{|t| eval(t) }
  end

  # def projects
  #   # Project.includes(:platform_tags).where(tags: { name: platform_tags.pluck(:name) })
  #   Project.public.includes(:platform_tags).references(:tags).where('lower(tags.name) IN (?)', platform_tags.pluck(:name).map{|n| n.downcase })
  #   # SearchRepository.new(q: platform_tags_string).search.results
  # end

  def logo_id=(val)
    self.logo = Logo.find_by_id(val)
  end

  def pro?
    plan == 'professional'
  end

  def shoplocket_token
    return unless shoplocket_link.present?

    shoplocket_link.split(/\//)[-1]
  end

  def reset_api_credentials=val
    reset_credentials('api') if val == true or val == '1'
  end

  def reset_portal_credentials=val
    reset_credentials('portal') if val == true or val == '1'
  end

  def reset_credentials type
    send "generate_#{type}_credentials", force: true
  end

  private
    def format_hashtag
      self.hashtag = '#' + hashtag if hashtag.present? and hashtag !~ /\A#/
    end

    def ensure_api_credentials
      generate_api_credentials unless api_username.present? and api_password.present?
    end

    def ensure_portal_credentials
      generate_portal_credentials unless http_password.present?
    end

    def ensure_platform_tags
      self.platform_tags_string = name if platform_tags_string.blank?
    end

    def generate_api_credentials opts={}
      self.api_username = SecureRandom.urlsafe_base64(nil, false) if api_username.blank? or opts[:force]
      self.api_password = Digest::SHA1.hexdigest([Time.now, rand].join) if api_password.blank? or opts[:force]
    end

    def generate_portal_credentials opts={}
      self.http_password = Digest::SHA1.hexdigest([Time.now, rand].join) if http_password.blank? or opts[:force]
    end

    def user_name_is_unique
      return unless new_user_name.present?

      slug = SlugHistory.where("LOWER(slug_histories.value) = ?", new_user_name.downcase).first
      errors.add :new_user_name, 'is already taken' if slug and slug.sluggable != self
    end
end