class ClientSubdomain < Subdomain
  include HerokuDomains
  include SetChangesForStoredAttributes
  include StringParser
  RESERVED_SUBDOMAINS = %w(www beta api admin)

  belongs_to :platform
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

  attr_accessible :subdomain, :domain, :logo_id, :name, :favicon_id,
    :hide_alternate_search_results, :analytics_code

  store :properties, accessors: [:hide_alternate_search_results, :analytics_code]
  set_changes_for_stored_attributes :properties
  parse_as_booleans :properties, :hide_alternate_search_results

  after_destroy do
    remove_domain_from_heroku(domain) unless domain.blank?
  end
  after_save :update_domains_on_heroku

  def favicon_id=(val)
    self.favicon = Favicon.find_by_id val
  end

  def logo_id=(val)
    self.logo = Logo.find_by_id val
  end

  private
  def update_domains_on_heroku
    if domain_changed?
      remove_domain_from_heroku(domain_was) unless domain_was.blank?
      add_domain_to_heroku(domain) unless domain.blank?
    end
  end
end