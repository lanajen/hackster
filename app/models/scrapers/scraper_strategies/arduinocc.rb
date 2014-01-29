module ScraperStrategies
  class Arduinocc < Base

    private
      def extract_title
        @parsed.at_css('.postSubject').text.strip
      end

      def select_article
        @parsed.at_css('.post')
      end
  end
end