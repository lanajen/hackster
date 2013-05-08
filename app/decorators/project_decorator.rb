class ProjectDecorator < ApplicationDecorator

  def description
    if model.description.present?
      model.description.html_safe
    else
      "No description has been entered yet."
    end
  end

  def logo size=:thumb
    if model.logo and model.logo.file_url
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
      logo = "project_default_logo_#{width}.png"
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
      image = 'project_default_headline.png'
    end

    link_to_model h.image_tag(image, alt: model.name)
  end
end
