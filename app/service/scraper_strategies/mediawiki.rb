module ScraperStrategies
  class Mediawiki < Base

    def crap_list
      super + %w(#toc)
    end

    def image_caption_container_classes
      super + %w(thumbinner)
    end

    def image_caption_elements
      super + %w(.thumbcaption)
    end

    private
      def extract_title
        @parsed.at_css('h1').try(:remove).try(:text).try(:strip) || @parsed.title
      end

      def select_article
        @parsed.at_css('#mw-content-text')
      end
  end
end