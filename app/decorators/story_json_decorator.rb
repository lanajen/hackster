module StoryJsonDecorator
  private
    def parse_story_json story
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
          embed_html data, 'Carousel'
        when 'Video'
          video = item['video'][0]
          data = { url: video['embed'], caption: video['figcaption'] }
          embed_html data, 'Video'
        when 'File'
          data = { id: item['id'] }
          embed_html data, 'File'
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
          tag = '<' + item['tag'] + '>'
          innards = item['content']
          children = item['children'].length < 1 ? '' : build_html(item['children'])
          "#{tag}#{innards}#{children}</#{item['tag']}>"
        }.join('')
      end
    end

    def embed_html data, type
      case type
      when 'Carousel'
        h.render partial: "api/embeds/carousel", locals: { images: data[:images], uid: data[:hash] }
      when 'Video'
        embed = Embed.new url: data[:url], default_caption: data[:caption]
        h.render partial: "api/embeds/embed", locals: { embed: embed, caption: data[:caption] }
      when 'File'
        embed = Embed.new file_id: data[:id]
        h.render partial: "api/embeds/embed", locals: { embed: embed }
      else
        ''
      end
    end
end