class ProjectDecorator < ApplicationDecorator
  include MediumEditorDecorator

  def cover_image version=:cover
    if model.cover_image
      if model.cover_image.file_url
        model.cover_image.file_url(version)
      elsif model.cover_image.tmp_file.present?
        h.asset_url "project_#{version}_image_processing.png"
      end
    else
      h.asset_url "project_default_#{version}_image.png"
    end
  end

  def description mode=:normal
    # options = (mode == :edit ? { except: ['PartsWidget'] } : {})
    parse_medium model.description#, options
  end

  def logo size=nil, use_default=true
    if model.logo and model.logo.file_url
      model.logo.file_url(size)
    elsif use_default
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
      "project_default_logo_#{width}.png"
    end
  end

  def logo_link size=:thumb
    link_to_model h.image_tag(logo(size), alt: model.name, class: 'img-responsive')
  end

  def logo_or_placeholder
    if model.logo and model.logo.file
      h.image_tag logo(:big), class: 'img-circle project-logo'
    else
      h.content_tag(:div, '', class: 'logo-placeholder')
    end
  end

  def name_not_default
    model.name == Project::DEFAULT_NAME ? nil : model.name
  end
end
