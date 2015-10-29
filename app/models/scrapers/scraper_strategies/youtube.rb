module ScraperStrategies
  class Youtube < Base

    private
      def after_parse
        tags = @parsed.css('.watch-info-tag-list a')
        @project.product_tags_string = tags.map{|a| a.text }[0..2].join(',')
        @project.one_liner = @parsed.at_css('meta[itemprop="description"]').try(:[], 'content').try(:truncate, 140)
        @project.content_type = :video

        super
      end

      def extract_cover_image
        img = @parsed.at_css('link[itemprop="thumbnailUrl"]')
        src = img['href']
        return src if test_link src
        nil
      end

      def extract_title
        @parsed.at_css('#watch-headline-title h1').remove.text.strip
      end

      def parse_cover_image
        # raise extract_cover_image.to_s
        if src = extract_cover_image
          image = @project.build_cover_image
          image.skip_file_check!
          image.remote_file_url = test_link src
        end
      end

      def select_article
        text = "<div class='embed-frame' data-url='#{@page_url}' data-type='url' data-caption='#{@page_url}'></div>"

        desc = @parsed.at_css('#eow-description').inner_html
        desc.split(/<br>/).each do |el|
          text += '<p>' + el + '</p>'
        end
        Nokogiri::HTML::DocumentFragment.parse(text)
      end
  end
end