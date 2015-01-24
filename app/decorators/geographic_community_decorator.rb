class GeographicCommunityDecorator < GroupDecorator

  def short_address
    if model.country.in? ['United States', 'Canada']
      "#{model.city}, #{model.state}"
    else
      model.city
    end
  end

  def short_location
    locations = []
    locations << model.city if model.city.present?
    locations << model.state if model.state.present?
    locations << model.country if model.country.present?
    locations.join(', ')
  end
end