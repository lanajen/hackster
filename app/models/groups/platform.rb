class Platform < List
  include Taggable

  MINIMUM_FOLLOWERS = 5
  MINIMUM_FOLLOWERS_STRICT = 20
  MODERATION_LEVELS = {
    'Approve all automatically' => 'auto',
    'Only projects approved by the Hackster team' => 'hackster',
    'Only projects approved by our team' => 'manual',
  }

  PROJECT_IDEAS_PHRASING = ['"No #{name} yet?"', '"Have ideas on what to build with #{name}?"']

  has_many :active_members, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'") }, foreign_key: :group_id, class_name: 'PlatformMember'
  has_many :announcements, as: :threadable, dependent: :destroy
  has_many :challenges
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'PlatformMember'
  has_many :parts

  has_many :part_projects, through: :parts, class_name: 'Project', source: :projects
  has_many :sub_parts, through: :parts, class_name: 'Part', source: :parent_parts
  has_many :sub_parts_projects, through: :parts, class_name: 'Project', source: :parent_projects
  has_many :sub_platforms, through: :related_parts, class_name: 'Platform', source: :platform

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

  attr_accessible :forums_link, :documentation_link, :crowdfunding_link,
    :buy_link, :shoplocket_link, :cover_image_id, :accept_project_ideas,
    :project_ideas_phrasing, :client_subdomain_attributes, :logo_id,
    :download_link, :company_logo_id, :disclaimer,
    :cta_text, :parts_attributes, :verified, :enable_chat, :enable_products,
    :description, :enable_parts, :enable_password, :enable_sub_parts

  accepts_nested_attributes_for :client_subdomain, :parts

  # before_save :update_user_name
  before_save :format_hashtag, :ensure_extra_credentials

  store_accessor :websites, :forums_link, :documentation_link,
    :crowdfunding_link, :buy_link, :shoplocket_link, :download_link
  set_changes_for_stored_attributes :websites

  store_accessor :properties, :accept_project_ideas, :project_ideas_phrasing,
    :active_challenge, :disclaimer, :cta_text, :hashtag,
    :verified, :enable_chat, :enable_products, :description, :enable_parts,
    :api_username, :api_password, :http_password, :enable_password,
    :enable_sub_parts
  set_changes_for_stored_attributes :properties

  parse_as_booleans :properties, :accept_project_ideas, :active_challenge,
    :is_new, :enable_comments, :hidden, :verified, :enable_chat, :enable_products,
    :enable_parts, :enable_password, :enable_sub_parts

  store_accessor :counters_cache, :parts_count, :products_count, :sub_parts_count

  parse_as_integers :counters_cache, :external_projects_count,
    :private_projects_count, :products_count, :parts_count, :sub_parts_count

  taggable :platform_tags, :product_tags

  is_impressionable counter_cache: true, unique: :session_hash

  has_default :products_text, 'Products built with %name%'
  has_default :moderation_level, 'hackster'

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
    where("groups.members_count > ?", MINIMUM_FOLLOWERS)
  end

  def self.minimum_followers_strict
    where("groups.members_count > ?", MINIMUM_FOLLOWERS_STRICT)
  end

  def company_logo_id=(val)
    self.company_logo = CompanyLogo.find_by_id(val)
  end

  def counters
    super.merge({
      external_projects: 'projects.external.count',
      private_projects: 'projects.private.count',
      parts: 'parts.count',
      products: 'products.count',
      projects: 'projects.visible.count',
      sub_parts: 'sub_parts.count',
    })
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

  def project_ideas_phrasing
    super || project_ideas_phrasing_options[0]
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

  def shoplocket_token
    return unless shoplocket_link.present?

    shoplocket_link.split(/\//)[-1]
  end

  private
    def format_hashtag
      self.hashtag = '#' + hashtag if hashtag.present? and hashtag !~ /\A#/
    end

    def ensure_extra_credentials
      generate_extra_credentials unless api_username.present? and api_password.present? and http_password.present?
    end

    def generate_extra_credentials opts={}
      self.api_username = SecureRandom.urlsafe_base64(nil, false) if api_username.blank? or opts[:force]
      self.api_password = Digest::SHA1.hexdigest([Time.now, rand].join) if api_password.blank? or opts[:force]
      self.http_password = Digest::SHA1.hexdigest([Time.now, rand].join) if http_password.blank? or opts[:force]
    end

    def user_name_is_unique
      return unless new_user_name.present?

      slug = SlugHistory.where("LOWER(slug_histories.value) = ?", new_user_name.downcase).first
      errors.add :new_user_name, 'is already taken' if slug and slug.sluggable != self
    end
end