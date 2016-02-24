class PromotionJsonDecorator < GroupJsonDecorator
  def node
    node = super
    node.merge! hash_for(%w())
    node
  end
end