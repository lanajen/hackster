class StoreProductDecorator < ApplicationDecorator
  def name
    model.name.presence || model.source.name
  end
end