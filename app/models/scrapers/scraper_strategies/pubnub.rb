module ScraperStrategies
  class Pubnub < Base

    private
      def before_parse
        tags = @parsed.css('.article-footer a[rel="tag"]')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')
        desc = @parsed.at_css('meta[property="og:description"]').try(:[], 'content').try(:truncate, 140)
        @project.one_liner = desc
      end

      def extract_title
        @parsed.at_css('.article-header h1').text.strip
      end

      def image_caption_container_classes
        super + %w(wp-caption)
      end

      def image_caption_elements
        super + %w(.wp-caption-text)
      end

      def select_article
        @parsed.at_css('.article-content')
      end
  end
end