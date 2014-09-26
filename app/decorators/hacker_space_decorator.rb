class HackerSpaceDecorator < GroupDecorator
  def short_location
    locations = []
    locations << model.city if model.city.present?
    locations << model.state if model.state.present?
    locations << model.country if model.country.present?
    locations.join(', ')
  end
end