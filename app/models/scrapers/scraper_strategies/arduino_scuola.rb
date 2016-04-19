module ScraperStrategies
  class ArduinoScuola < Base

    private
      def after_parse
        extract_components

        super
      end

      def before_parse
        @project.one_liner = @parsed.at_css('.clearfix.clear.row').try(:text).try(:strip).try(:truncate, 140)
        @project.duration = (@parsed.at_css('.time_box').text.to_f / 60).round(2)
        @project.cost = @parsed.at_css('.money_box').text.to_f
        @project.product_tags_string = @parsed.css('.lesson_tag').map{|a| a.text }.join(',')
        @project.guest_name = @parsed.at_css('.lessonDetailsBar a').text.strip
        tags = @project.product_tags_string.split(',').map{|t| t.downcase }

        super
      end

      def extract_cover_image
        @parsed.at_css('.cover_box img')
      end

      def extract_components
        parts = @parsed.css('.componentWrapper')
        return unless parts.any?

        parts.each_with_index do |comp, i|
          part = HardwarePart.new
          part.name = comp.at_css('.componentName').text.strip
          part.save

          part_join = PartJoin.new part_id: part.id, partable_id: 0,
            partable_type: 'BaseArticle'
          part_join.position = i + 1
          @parts << part_join
        end
      end

      def extract_title
        @parsed.at_css('h3').text.strip
      end

      def select_article
        content = fetch_page @host + @base_uri.gsub(/cover/, 'view')
        doc = Nokogiri::HTML(content)

        text = doc.css('.lesson_step_block').map(&:to_s).join('')
        article = Nokogiri::HTML::DocumentFragment.parse(text)
        article.css('h4').each do |node|
          node.name = 'h3'
        end
        article
      end
  end
end