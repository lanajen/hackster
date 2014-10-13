module MediumEditorDecorator
  private
    def parse_medium model_attribute
      if model_attribute.present?
        parsed = Nokogiri::HTML::DocumentFragment.parse model_attribute

        parsed.css('.embed-frame').each do |el|
          begin
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

            next unless embed.provider_name
            code = h.render partial: "api/embeds/embed", locals: { embed: embed }
            next unless code
            code = code.try(:force_encoding, "UTF-8")  # somehow slim templates come out as ASCII

            if caption = el['data-caption']
              code = Nokogiri::HTML::DocumentFragment.parse code
              if figcaption = code.at_css('.embed-figcaption')
                figcaption.content = caption
                code = code.to_html
              end
            end

            el.add_child code if code
          rescue
            # el.add_child "<p>Something should be showing up here but an error occurred. Send this info to team@hackster.io: data-type: #{el['data-type']}, data-url: #{el['data-url']}, data-widget-id: #{el['data-widget-id']}. Thanks!</p>"
            el.remove
            next
          end
        end
        parsed.to_html.html_safe
      else
        "<p class='paragraph--empty'><br></p>".html_safe
      end
    end
end