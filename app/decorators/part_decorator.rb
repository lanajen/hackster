class PartDecorator < ApplicationDecorator
  def image size=:thumb
    if model.image and model.image.file_url
      model.image.imgix_url(size)
    end
  end

  def image_link size=:thumb
    link_to_model h.image_tag(image(size), alt: model.name)
  end

  def name_link
    link_to_model model.name
  end

  def one_liner_or_description
    model.one_liner.presence || h.strip_tags(model.description).try(:truncate, 140).try(:html_safe)
  end
end