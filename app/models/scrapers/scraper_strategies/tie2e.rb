module ScraperStrategies
  class Tie2e < Base

    private
      def before_parse
        tags = @parsed.css('.tag-list a')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')

        super
      end

      def crap_list
        super + %w(.author .actions .content-tags)
      end

      def extract_title
        @parsed.at_css('h3.name a').text.strip
      end

      def select_article
        @parsed.at_css('.content.full > .content') || @parsed.at_css('.media-gallery-post .content-fragment-content')
      end
  end
end