class ClientSubdomain < Subdomain
  include HasDefault
  include HerokuDomains
  include HstoreColumn
  AVAILABLE_LOCALES = {
    'Chinese (zh)' => 'zh',
    'Chinese - China (zh-CN)' => 'zh-CN',
    'English (en)' => 'en',
    'English - American (en-US)' => 'en-US',
  }
  RESERVED_SUBDOMAINS = %w(www beta api admin)

  belongs_to :platform, inverse_of: :client_subdomain
  has_one :favicon, as: :attachable
  has_one :logo, as: :attachable, class_name: 'Document'

  validates :domain, length: { in: 3..100 }, allow_blank: true
  validates :domain, exclusion: { in: %w(www.hackster.io www.hackster.com hackster.io hackster.com), message: "Domain %{value} is reserved" }
  validates :domain, uniqueness: true, allow_blank: true
  validates :domain, format: { with: /\A[a-z0-9\-]+\.[a-z0-9\-]+\.[a-z]{2,4}(\.[a-z]{2,4})?\z/, message: 'is not a valid domain. Valid example: "www.hackster.io" (includes subdomain like "www").' }, allow_blank: true

  validates :subdomain, format: { with: /\A[a-z0-9\-]+\z/, message: 'is not a valid subdomain. Please use only lowercase letters, digits or dash (-).' }, allow_blank: true
  validates :subdomain, presence: true
  validates :subdomain, length: { in: 3..60 }, allow_blank: true
  validates :subdomain, exclusion: { in: RESERVED_SUBDOMAINS, message: "Subdomain %{value} is reserved" }
  validates :subdomain, uniqueness: true
  validate :default_locale_is_active

  attr_accessible :subdomain, :domain, :logo_id, :name, :favicon_id,
    :hide_alternate_search_results, :analytics_code

  store :properties, accessor: []
  hstore_column :properties, :active_locales, :array, default: I18n.active_locales.map{|v| v.to_s }
  hstore_column :properties, :analytics_code, :string
  hstore_column :properties, :default_avatar_url, :string
  hstore_column :properties, :default_project_cover_image_file_path, :string
  hstore_column :properties, :default_locale, :string, default: I18n.default_locale
  hstore_column :properties, :disable_login, :boolean
  hstore_column :properties, :disable_https, :boolean
  hstore_column :properties, :disable_onboarding_screens, :boolean, default: false
  hstore_column :properties, :enable_custom_avatars, :boolean, default: false
  hstore_column :properties, :enable_localization, :boolean, default: false
  hstore_column :properties, :enabled, :boolean, default: false
  hstore_column :properties, :force_explicit_locale, :boolean, default: false
  hstore_column :properties, :hide_alternate_search_results, :boolean
  hstore_column :properties, :path_prefix, :string

  has_default :name, '%{platform.try(:name)} Projects' do |instance|
    instance.read_attribute :name
  end

  after_destroy do
    remove_domain_from_heroku(domain) unless domain.blank?
  end
  after_save :update_domains_on_heroku

  def base_uri scheme='http'
    _base_uri = "#{scheme}://#{full_domain}"
    _base_uri << path_prefix if has_path_prefix?
    _base_uri
  end

  def has_default_avatar?
    default_avatar_url.present?
  end

  def has_default_project_cover_image?
    default_project_cover_image_file_path.present?
  end

  def has_path_prefix?
    path_prefix.present?
  end

  def favicon_id=(val)
    self.favicon = Favicon.find_by_id val
  end

  def logo_id=(val)
    self.logo = Logo.find_by_id val
  end

  private
    def default_locale_is_active
      errors.add :default_locale, 'is not in the list of active locales' unless default_locale.in? active_locales
    end

    def update_domains_on_heroku
      if domain_changed?
        remove_domain_from_heroku(domain_was) unless domain_was.blank?
        add_domain_to_heroku(domain) unless domain.blank?
      end
    end
end