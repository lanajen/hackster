module ScraperStrategies
  class AutodeskCircuit < Base

    private
      def after_parse
        @widgets << SchematicWidget.new(url: @page_url, name: 'Autodesk 123 Circuits Schematics')

        super
      end

      def crap_list
        super + %w(.show__comments)
      end

      def extract_title
        @parsed.at_css('.show__details__titleitem.show__details__title').text.strip
      end

      def select_article
        @parsed.at_css('.show__overview')
      end
  end
end