class ProjectJsonDecorator < BaseJsonDecorator
  def node
    node = model.map do |project|
      project = {
        id: project.id,
        name: project.name,
        one_liner: project.one_liner,
        cover_image_url: project.decorate.cover_image(:cover_thumb),
        created_at: project.created_at.strftime('%Y-%m-%d')
      }
    end
    node
  end
end