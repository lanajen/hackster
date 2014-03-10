module ScraperStrategies
  class Kickstarter < Base

    private
      def before_parse
        @project.one_liner = @parsed.at_css('.short_blurb').text.truncate(140)
        super
      end

      def extract_title
        @parsed.at_css('#project-header h2').text.strip
      end

      def parse_images
        image_widget = ImageWidget.new name: 'Photos'
        collection = {}
        @article.css('figure').each do |fig|
          img = fig.at_css('img')
          src = normalize_image_link get_src_for_img(img)
          next unless test_link(src)
          caption = fig.at_css('figcaption').try(:text)
          collection[src] = caption
        end

        i = 0
        collection.each do |src, title|
          puts "Parsing image #{src}..."
          image = image_widget.images.new(remote_file_url: src, title: title.try(:truncate, 255), position: i)
          image.skip_file_check!
          i += 1
        end
        @widgets << image_widget if image_widget.images.any?

        if img = collection.first
          image = @project.build_cover_image remote_file_url: img[0]
          image.skip_file_check!
        end
      end

      def select_article
        @parsed.at_css('.full-description')
      end

      def title_levels
        1..4
      end
  end
end