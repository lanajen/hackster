class ProjectDecorator < ApplicationDecorator

  def logo size=:thumb
    if model.logo
      logo = model.logo.file_url(size)
    else
      width = case size
      when :tiny
        20
      when :mini
        40
      when :thumb
        60
      when :medium
        80
      when :big
        200
      end
      logo = "http://placehold.it/#{width}"
    end
    logo
  end

  def logo_link size=:thumb
    link_to_model h.image_tag(logo(size), alt: model.name)
  end

  def image_link size=:thumb
    if model.image
      image = model.image.file_url(size)
    else
      image = "http://placehold.it/210x118"
    end

    link_to_model h.image_tag(image, alt: model.name)
  end
end
