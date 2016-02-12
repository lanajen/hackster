class GeographicCommunity < Community
  geocoded_by :full_street_address
  after_validation :geocode, if: proc{|h| h.address_changed? or h.city_changed? or
    h.state_changed? or h.country_changed? }

  validates :address, length: { maximum: 255 }

  attr_accessible :address, :state, :zipcode, :latitude, :longitude

  def to_indexed_json
    super.merge!({
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      state: state,
    })
  end

  def full_street_address
    locations = []
    locations << address if address.present?
    locations << city if city.present?
    locations << state if state.present?
    locations << zipcode if zipcode.present?
    locations << country if country.present?
    locations.join(', ')
  end
end