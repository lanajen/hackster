module ScraperStrategies
  class Discourse < Base

    private
      def before_parse
        @article.css('.emoji').each do |emoji|
          type = emoji['title']
          if text = emoji_to_text[type]
            emoji.before Nokogiri::XML::Text.new(text, @article)
          end
          emoji.remove
        end

        @article.css('.lazyYT').each do |el|
          yt = el['data-youtube-id']
          iframe = Nokogiri::XML::Node.new 'iframe', @article
          url = "http://youtu.be/#{yt}"
          iframe['src'] = url
          el.after iframe
          el.remove
        end
      end

      def crap_list
        super + %w(.meta)
      end

      def extract_title
        @parsed.at_css('#main-outlet h2').try(:text).try(:strip) || @parsed.at_css('#main-outlet h1').text.strip
      end

      def emoji_to_text
        {
          ':angry:' => ':(',
          ':cry:' => ":'(",
          ':disappointed:' => ':(',
          ':laughing:' => 'xD',
          ':satisfied:' => 'xD',
          ':smile:' => ':)',
          ':smiley:' => ':)',
          ':wink:' => ';)',
        }
      end

      def select_article
        @parsed.at_css('#main-outlet .post') || @parsed.at_css('#main-outlet .topic-body .contents')
      end
  end
end