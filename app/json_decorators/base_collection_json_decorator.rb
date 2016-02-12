class BaseCollectionJsonDecorator
  include JsonDecoratorHelpers
  attr_accessor :collection

  def initialize collection, opts={}
    @collection = collection
    @opts = opts
  end

  def node
    collection.map do |model|
      "#{model.class.name}JsonDecorator".constantize.new(model, @opts).node
    end
  end
end