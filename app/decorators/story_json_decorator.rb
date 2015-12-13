module StoryJsonDecorator
  private
    def parse_story_json story, options={}
      story.map { |item|
        case item['type']
        when 'CE'
          build_html item['json']
        when 'Carousel'
          hash = {}
          images = item['images'].each_with_index do |img, i|
            hash[img['id']] = { caption: img['figcaption'], position: i }
          end
          data = { images: hash, hash: item['hash'] }
          embed_html data, 'Carousel', options
        when 'Video'
          video = item['video'][0]
          data = { url: video['embed'], caption: video['figcaption'] }
          embed_html data, 'Url', options
        when 'File'
          if(item['data']['id'] != nil)
            data = { id: item['data']['id'] }
            embed_html data, 'File', options
          else
            ''
          end
        when 'WidgetPlaceholder'
          # URL Widgets with a type of 'repo' get transformed into WidgetPlaceholders.  'embed' is the url.
          if item['data']['type'] == 'repo'
            data = { url: item['data']['embed']}
            embed_html data, 'Url', options
          else
            data = { id: item['data']['id']}
            embed_html data, 'Widget', options
          end
        else
          ''
        end
      }.join('')
    end

    def build_html json
      if json.empty?
        json
      else
        json.map { |item|
          href = item['tag'] === 'a' ? " href='#{item['attribs']['href']}'" : ''
          tag = '<' + item['tag'] + href + '>'
          innards = item['content']
          children = item['children'].length < 1 ? '' : build_html(item['children'])
          "#{tag}#{innards}#{children}</#{item['tag']}>"
        }.join('')
      end
    end

    def embed_html data, type, options
      case type
      when 'Carousel'
        h.render partial: "api/embeds/carousel", locals: { images: data[:images], uid: data[:hash], options: options }
      when 'Url'
        embed = Embed.new url: data[:url], default_caption: data[:caption]
        h.render partial: "api/embeds/embed_frame", locals: { embed: embed, caption: data[:caption], options: options }
      when 'File'
        embed = Embed.new file_id: data[:id]
        h.render partial: "api/embeds/embed_frame", locals: { embed: embed, options: options }
      when 'Widget'
        embed = Embed.new widget_id: data[:id]
        h.render partial: "api/embeds/embed_frame", locals: { embed: embed, options: options }
      else
        ''
      end
    end
end