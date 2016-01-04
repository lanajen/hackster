class LiveEventSetsController < ApplicationController
  def index
    @events = LiveEventSetDecorator.decorate_collection(LiveEventSet.order(:virtual, :country, :city))
  end
end