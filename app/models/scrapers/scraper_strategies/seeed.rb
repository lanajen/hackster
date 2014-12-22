module ScraperStrategies
  class Seeed < Base

    private
      def before_parse
        @article.at_css('h1').remove

        tags = @parsed.css('.sideTags .tags a')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')

        els = @parsed.css('.c9')
        if el = els.last
          @project.guest_name = el.text.strip
        end
        @project.platform_tags_string = 'Seeed'

        # parse_comments
        super
      end

      def crap_list
        super + %w(.carousel-indicators)
      end

      def extract_title
        @parsed.at_css('h1').remove.text.strip
      end

      def select_article
        bits = @parsed.at_css('.carouselSlid').to_html
        bits += @parsed.css('.infoBox, #step_detail').map{|t| t.to_html}.join('')
        Nokogiri::HTML::DocumentFragment.parse(bits)
      end
  end
end