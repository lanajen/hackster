module ScraperStrategies
  class Pubnub < Base

    private
      def before_parse
        tags = @parsed.css('.article-footer [rel=tag]')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')
      end

      def extract_title
        @parsed.at_css('.article-header h1').text.strip
      end

      def select_article
        @parsed.at_css('.article-content')
      end
  end
end