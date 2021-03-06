module ScraperStrategies
  class Seeed < Base

    private
      def after_parse
        extract_components

        super
      end

      def before_parse
        tags = @parsed.css('.sideTags .tags a')
        @project.product_tags_string = tags.map{|a| a.text }[0..2].join(',')

        # els = @parsed.css('.public-info .mr')
        # if el = els.first
        #   @project.guest_name = el.text.gsub(/Contributors: /, '').strip
        # end
        @project.platform_tags_string = 'Seeed'

        # parse_comments
        super
      end

      def crap_list
        super + %w(.carousel-indicators)
      end

      def extract_components
        parts = @parsed.css('.products .tile')
        return unless parts.any?



        parts.each_with_index do |comp, i|
          part = HardwarePart.new
          part.name = comp.at_css('.tile-title').text.strip
          if store_link = comp.at_css('.tile-title a').try(:[], 'href')
            part.store_link = normalize_link store_link
          end
          part.save

          part_join = PartJoin.new part_id: part.id, partable_id: 0,
            partable_type: 'BaseArticle'
          part_join.position = i + 1
          @parts << part_join
        end
      end

      def extract_title
        @parsed.at_css('h1').remove.text.strip.split(/\n/)[0]
      end

      def select_article
        text = @parsed.at_css('#step_detail').to_html
        text ||= ''
        text += @parsed.at_css('.section-links').try(:to_html) if @parsed.at_css('.section-links')
        Nokogiri::HTML::DocumentFragment.parse(text)
      end
  end
end