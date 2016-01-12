module MediumEditorDecorator
  private
    def parse_medium model_attribute, options={}
      if model_attribute.present?
        parsed = Nokogiri::HTML::DocumentFragment.parse model_attribute

        parsed.css('h3').each do |el|
          if el.content
            el['id'] = el.content.downcase.gsub(/[^a-zA-Z0-9]$/, '').strip.gsub /[^a-z]/, '-'
          end
        end

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
              widget = if options[:widgets]
                options[:widgets].select{|w| w.id.to_s == el['data-widget-id'] }.first
              else
                Widget.find_by_id el['data-widget-id']
              end
              embed = Embed.new widget: widget, images: options[:images]
              raise "widget ID #{el['data-widget-id']} not found, widget: #{widget.inspect}" if embed.widget.nil?

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
            code = h.render partial: "api/embeds/embed#{template_append}", locals: { embed: embed, options: options }
            next unless code
            code = code.try(:force_encoding, "UTF-8")  # somehow slim templates come out as ASCII

            if caption = el['data-caption'] and caption != 'Type in a caption'
              code = Nokogiri::HTML::DocumentFragment.parse code
              if figcaption = code.at_css('.embed-figcaption')
                figcaption.content = caption
                code = code.to_html
              end
            end

            el.add_child code if code
          rescue
            # el.add_child "<p>Something should be showing up here but an error occurred. Send this info to help@hackster.io: data-type: #{el['data-type']}, data-url: #{el['data-url']}, data-widget-id: #{el['data-widget-id']}. Thanks!</p>"
            el.remove
            next
          end
        end
        parsed.to_html.html_safe
      else
        return nil;
        # "<p class='paragraph--empty'><br></p>".html_safe
      end
    end
end