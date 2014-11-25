module ScraperStrategies
  class Onesheeld < Base

    private
      def after_parse

        tags = @parsed.css('.meta-list li:not(.post-author) a:not(.fa)')
        @project.product_tags_string = tags.map{|a| a.text }.select{|a| a.present? }.join(',')
        @project.guest_name = @parsed.at_css('.post-author a').try(:text).try(:strip)

        # parse_comments
        super
      end

      def before_parse
      #   @article.css('.photoset-photo').each do |img|
      #     while img.parent.name != 'a'
      #       img.parent.parent.add_child img
      #     end
      #   end
        @article.css('.photo-container').each{ |node| unwrap node }
        @article.css('.photoset .row').each{ |node| unwrap node }
        @article.css('br').each{|el| el.remove }

        super
      end

      def extract_cover_image
        @parsed.at_css('.post-img img')
      end

      def extract_images base=@article, super_base=nil
        base.css('.photoset-link').reverse.each do |img|
          until img.parent['class'] == 'photoset'
            img.parent.parent.add_child img
          end
        end

        super base, super_base
      end

      def extract_title
        @parsed.at_css('h1').remove.text.strip
      end

      def parse_cover_image
        if img = extract_cover_image
          src = normalize_link img['src']
          image = @project.build_cover_image
          image.skip_file_check!
          image.remote_file_url = src
        end
      end

      def select_article
        @parsed.at_css('.post-content')
      end
  end
end