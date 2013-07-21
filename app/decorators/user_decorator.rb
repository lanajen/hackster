class UserDecorator < AccountDecorator
  def avatar size=:thumb
    if model.avatar and model.avatar.file_url
      avatar = model.avatar.file_url(size)
    else
      avatar = gravatar size
    end
    avatar
  end

  def avatar_link size=:thumb
    link_to_model h.image_tag(avatar(size), alt: model.name)
  end

  def name_link
    link_to_model model.name
  end
end