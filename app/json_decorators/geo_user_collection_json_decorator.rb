class GeoUserCollectionJsonDecorator < BaseCollectionJsonDecorator
  def node opts={}
    node = {}
    node[:users] = collection.map do |model|
      GeoUserJsonDecorator.new(model).node(opts)
    end
    node[:nextPage] = collection.next_page if collection.respond_to?(:next_page)
    node
  end
end