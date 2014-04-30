module ScraperStrategies
  class SparkForum < Base

    private
      def after_parse
        @project.tech_tags_string = 'Spark Core'
        super
      end

      def extract_title
        @parsed.at_css('h2').remove.text
      end

      def select_article
        @parsed.at_css('.post')
      end
  end
end