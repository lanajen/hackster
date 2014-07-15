class ProjectDecorator < ApplicationDecorator

  def cover_image version=:cover
    if model.cover_image and model.cover_image.file_url
      model.cover_image.file_url(version)
    else
      h.asset_url "project_default_#{version}_image.png"
    end
  end

  def description
    if model.description.present?
      parsed = Nokogiri::HTML::DocumentFragment.parse model.description

      parsed.css('.embed-frame').each do |el|
        link = if el['data-embed']
          el['data-embed']
        elsif file_id = el['data-file-id']
          if file = Attachment.find_by_id(file_id)
            file.file_url
          end
        end
        next unless link

        code = Embed.new(link).code

        puts link.inspect
        puts code.inspect

        if caption = el['data-caption']
          code = Nokogiri::HTML::DocumentFragment.parse code
          figcaption = code.at_css('figcaption')
          figcaption.content = caption
          code = code.to_html
        end
        el.add_child code if code
      end
      parsed.to_html.html_safe
    else
      ""
    end
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
end
