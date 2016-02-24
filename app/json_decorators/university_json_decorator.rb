class UniversityJsonDecorator < GeographicCommunityJsonDecorator
  def node
    node = super
    node.merge! hash_for(%w())
    node[:avatar_url] = model.decorate.avatar(:big)
    node
  end
end