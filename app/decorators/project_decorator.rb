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
        type = el['data-type']

        embed = case type
        when 'url'
          link = el['data-url']
          next unless link

          Embed.new url: link, fallback_to_default: true
        when 'file'
          file_id = el['data-file-id']
          next unless file_id

          Embed.new file_id: file_id
        when 'widget'
          Embed.new widget_id: el['data-widget-id']
        else
          next
        end

        code = h.render partial: "api/embeds/embed", locals: { embed: embed }
        next unless code

        if caption = el['data-caption']
          code = Nokogiri::HTML::DocumentFragment.parse code
          if figcaption = code.at_css('figcaption')
            figcaption.content = caption
            code = code.to_html
          end
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

  def name_not_default
    model.name == Project::DEFAULT_NAME ? nil : model.name
  end
end
