class ProjectJsonDecorator < BaseJsonDecorator
  def node
    node = hash_for(%w(id name one_liner))
    node[:cover_image_url] = model.decorate.cover_image(:cover_thumb)
    node
  end
end