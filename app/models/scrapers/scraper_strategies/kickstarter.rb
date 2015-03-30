module ScraperStrategies
  class Kickstarter < Base

    private
      def before_parse
        @project.one_liner = @parsed.at_css('meta[property="og:description"]')['content'].truncate(140)
        super
      end

      def extract_title
        @parsed.at_css('.NS_projects__header h2').text.strip
      end

      def select_article
        @parsed.at_css('.full-description')
      end

      def title_levels
        1..4
      end
  end
end