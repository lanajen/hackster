class GeographicCommunity < Community
  geocoded_by :full_street_address
  after_validation :geocode, if: proc{|h| h.address_changed? or h.city_changed? or
    h.state_changed? or h.country_changed? }

  validates :address, length: { maximum: 255 }

  attr_accessible :address, :state, :zipcode, :latitude, :longitude

  def full_street_address
    "#{address}, #{city}, #{state}, #{zipcode}, #{country}"
  end
end