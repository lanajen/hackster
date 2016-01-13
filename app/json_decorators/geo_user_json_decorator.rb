class GeoUserJsonDecorator < BaseJsonDecorator
  def node opts={}
    node = hash_for(%w())
    node[:lat] = model.latitude
    node[:lng] = model.longitude
    if opts[:load_all]
      node[:avatarUrl] = model.decorate.avatar(:mini)
      node[:name] = model.name
      node[:slug] = model.user_name
      node[:miniResume] = model.mini_resume
      node[:interests] = model.interest_tags_cached
      node[:skills] = model.skill_tags_cached
      node[:location] = model.full_location
    end
    node
  end
end