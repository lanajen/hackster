module ScraperStrategies
  class ArduinoForum < Base

    private
      def crap_list
        super + %w(.codeheader)
      end

      def extract_code_blocks base=@article
        base.css('code')
      end

      def extract_title
        @parsed.at_css('.subject_title').text.strip
      end

      def select_article
        text = ''
        article_author = @parsed.at_css('.poster a')['href']

        @parsed.css('.post_wrapper').each do |wrapper|
          author = wrapper.at_css('.poster a')['href']
          break if article_author != author

          text += wrapper.at_css('.post').to_s
        end

        Nokogiri::HTML::DocumentFragment.parse(text)
      end
  end
end