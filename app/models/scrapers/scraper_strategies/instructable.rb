module ScraperStrategies
  class Instructable < Base

    private
      def after_parse
        tags = @parsed.css('.ible-tags a')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')

        # parse_comments
        super
      end

      def extract_title
        @parsed.at_css('h1').remove.text
      end

      def select_article
        steps = @parsed.css('#main-content .step-container').map{|t| t.to_html}.join('')
        Nokogiri::HTML::DocumentFragment.parse(steps)
      end
  end
end