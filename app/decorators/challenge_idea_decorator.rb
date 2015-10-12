class ChallengeIdeaDecorator < ChallengeEntryDecorator
  def image size=:thumb
    if model.image and model.image.file_url
      model.image.imgix_url(size)
    else
      h.asset_url "project_default_large_image.png"
    end
  end

  def image_tag size=:thumb
    if image(size)
      h.image_tag image(size)
    end
  end
end