module ScraperStrategies
  class Instructable < Base

    private
      def after_parse
        tags = @parsed.css('.ible-tags a')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')

        # parse_comments
        super
      end

      def before_parse
        @article.css('.lazyphoto').each{|n| n.remove }
        @article.css('.photoset-photo').each do |img|
          while img.parent.name != 'a'
            img.parent = img.parent.parent
          end
        end

        @article.css('.photoset-link').each do |img|
          until img.parent['class'] == 'photoset'
            img.parent = img.parent.parent
          end
        end

        super
      end

      def crap_list
        super + %w(.inline-ads)
      end

      def extract_title
        @parsed.at_css('h1').remove.text.strip
      end

      def select_article
        steps = @parsed.css('#main-content .step-container').map{|t| t.to_html}.join('')
        Nokogiri::HTML::DocumentFragment.parse(steps)
      end
  end
end