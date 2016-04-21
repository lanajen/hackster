class ProjectJsonDecorator < BaseJsonDecorator
  def node
    {
      id: model.id,
      name: model.name,
      one_liner: model.one_liner,
      cover_image_url: model.decorate.cover_image(:cover_thumb),
      created_at: model.created_at.strftime('%Y-%m-%d')
    }
  end
end