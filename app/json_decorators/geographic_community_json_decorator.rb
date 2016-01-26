class GeographicCommunityJsonDecorator < GroupJsonDecorator
  def node
    node = super
    node.merge! hash_for(%w(city country))
    node
  end
end