class BlogPostDecorator < ApplicationDecorator
  delegate :current_page, :total_pages, :limit_value

  def body
    if model.body.present?
      parsed = Nokogiri::HTML::DocumentFragment.parse model.body

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
      "<p class='paragraph--empty'><br></p>".html_safe
    end
  end

  def title_not_default
    model.title == BlogPost::DEFAULT_TITLE ? nil : model.title
  end
end
