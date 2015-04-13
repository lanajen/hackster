module MediumEditorDecorator
  private
    def parse_medium model_attribute, options={}
      if model_attribute.present?
        parsed = Nokogiri::HTML::DocumentFragment.parse model_attribute

        parsed.css('.embed-frame').each do |el|
          begin
            type = el['data-type']

            embed = case type
            when 'file'
              file_id = el['data-file-id']
              next unless file_id

              Embed.new file_id: file_id
            when 'url'
              link = el['data-url']
              next unless link

              Embed.new url: link, fallback_to_default: true
            when 'video'
              video_id = el['data-video-id']
              next unless video_id

              Embed.new video_id: video_id
            when 'widget'
              embed = Embed.new widget_id: el['data-widget-id']
              if options[:except]
                if embed.widget.type.in? options[:except]
                  el.remove
                  next
                end
              end
              embed
            else
              next
            end

            next unless embed.provider_name
            template_append = options[:print] ? '_print' : nil
            code = h.render partial: "api/embeds/embed#{template_append}", locals: { embed: embed }
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
            # el.add_child "<p>Something should be showing up here but an error occurred. Send this info to hi@hackster.io: data-type: #{el['data-type']}, data-url: #{el['data-url']}, data-widget-id: #{el['data-widget-id']}. Thanks!</p>"
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