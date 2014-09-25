class HackerSpaceDecorator < GroupDecorator
  def short_location
    "#{model.city}, #{model.state}, #{model.country}"
  end
end