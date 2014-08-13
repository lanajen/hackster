module ScraperStrategies
  class SparkForum < Base

    def crap_list
      super + ['.meta .informations']
    end

    def image_caption_container_classes
      super + %w(lightbox-wrapper)
    end

    def image_caption_elements
      super + ['.meta .filename']
    end

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