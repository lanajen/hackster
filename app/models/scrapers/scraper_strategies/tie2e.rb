module ScraperStrategies
  class Tie2e < Base

    private
      def before_parse
        tags = @parsed.css('.tag-list a')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')

        super
      end

      def extract_title
        @parsed.at_css('h3.name a').text.strip
      end

      def select_article
        @parsed.at_css('.content table')
      end
  end
end