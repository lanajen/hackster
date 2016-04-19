class ProjectJsonDecorator < BaseJsonDecorator
  def node
    node = model.map do |project|
      project = {
        id: project.id,
        name: project.name,
        image: project['cover_image_url'] ? project.cover_image_url  nil,
        communities: project.platforms || 'unlisted',
        created_at: project.created_at.strftime('%Y-%m-%d'),
        end
      }
    end
    node
  end
end