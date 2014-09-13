module ScraperStrategies
  class Medium < Base

    private
      def extract_title
        @parsed.at_css('h2').try(:text).try(:strip) || @parsed.at_css('h3').try(:text).try(:strip)
      end

      def select_article
        @parsed.at_css('.postWrapper')
      end
  end
end