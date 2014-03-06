class ClientSubdomain < Subdomain
  RESERVED_SUBDOMAINS = %w(www beta api admin)

  has_one :logo, as: :attachable, class_name: 'Document'

  validates :subdomain, format: { with: /\A[a-z0-9\-]+\z/, message: 'is not a valid subdomain. Please use only lowercase letters, digits or dash (-).' }, allow_blank: true
  validates :subdomain, presence: true
  validates :subdomain, length: { in: 3..60 }, allow_blank: true
  validates :subdomain, exclusion: { in: RESERVED_SUBDOMAINS, message: "Subdomain %{value} is reserved" }
  validates :subdomain, uniqueness: true
end