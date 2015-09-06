module ScraperStrategies
  class Makezine < Wordpress

    private
      def after_parse
        extract_components
        extract_one_liner
        super
      end

      def extract_components
        parts = @parsed.css('.parts-tools .tab-pane#1 li')
        process_components parts, part_class=HardwarePart

        parts = @parsed.css('.parts-tools .tab-pane#2 li')
        process_components parts, part_class=ToolPart
      end

      def extract_one_liner
        @project.one_liner = @parsed.at_css('meta[property="og:description"]').try(:[], 'content').try(:truncate, 140)
      end

      def extract_title
        @parsed.at_css('h1').try(:text).try(:strip)
      end

      def process_components parts, part_class=Part
        return unless parts.any?

        parts.each_with_index do |comp, i|
          part = part_class.new
          comment = comp.at_css('.muted').try(:text).try(:strip)
          name = comp.text.gsub(comment || '', '').strip
          name.match /\A([^\(]+)(?:\s+\(([0-9+])\))?\Z/
          quantity = $2.try(:to_i) || 1
          part.store_link = comp.at_css('a').try(:[], 'href')
          part.name = $1
          part.save
          raise part.errors.inspect unless part.persisted?

          part_join = PartJoin.new part_id: part.id, partable_id: 0,
            partable_type: 'Project'
          part_join.quantity = quantity
          part_join.comment = comment
          part_join.position = i + 1
          @parts << part_join
        end
      end

      def select_article
        @parsed.at_css('.projects.type-projects .span8')
      end
  end
end