class HackerSpace < Community
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'HackerSpaceMember'
  has_many :pages, as: :threadable

  store_accessor :websites, :irc_link, :hackerspace_org_link, :wiki_link,
    :mailing_list_link

  attr_accessible :irc_link, :hackerspace_org_link, :wiki_link, :mailing_list_link,
    :latitude, :longitude

  geocoded_by :full_street_address
  after_validation :geocode, if: proc{|h| h.address_changed? or h.city_changed? or
    h.state_changed? or h.country_changed? }

  validates :address, length: { maximum: 255 }

  attr_accessible :address, :state, :zipcode

  # beginning of search methods
  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 100
      indexes :mini_resume,     analyzer: 'snowball'
      indexes :city,            analyzer: 'snowball'
      indexes :country,         analyzer: 'snowball'
      indexes :state,           analyzer: 'snowball'
      indexes :private,         analyzer: 'keyword'
      indexes :created_at
    end
  end

  def to_indexed_json
    {
      _id: id,
      name: name,
      model: self.class.name,
      city: city,
      country: country,
      state: state,
      mini_resume: mini_resume,
      private: private,
      created_at: created_at,
    }.to_json
  end
  # end of search methods

  def self.default_access_level
    'anyone'
  end

  def full_street_address
    "#{address}, #{city}, #{state}, #{zipcode}, #{country}"
  end

  private
    def skip_website_check
      %w(irc_link mailing_list_link)
    end
end