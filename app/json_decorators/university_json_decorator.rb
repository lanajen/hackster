class UniversityJsonDecorator < GeographicCommunityJsonDecorator
  def node
    node = super
    node.merge! hash_for(%w())
    node
  end
end