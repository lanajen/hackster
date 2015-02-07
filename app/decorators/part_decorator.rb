class PartDecorator < ApplicationDecorator
  def image size=:thumb
    if model.image and model.image.file_url
      image = model.image.file_url(size)
    end
    image
  end

  def image_link size=:thumb
    link_to_model h.image_tag(avatar(size), alt: model.name)
  end

  def name_link
    link_to_model model.name
  end
end