class BaseCollectionJsonDecorator
  attr_accessor :collection

  def initialize collection
    @collection = collection
  end

  def node
    collection.map do |model|
      "#{model.class.name}JsonDecorator".constantize.new(model).node
    end
  end

  private
    def h
      ActionController::Base.helpers
    end
end