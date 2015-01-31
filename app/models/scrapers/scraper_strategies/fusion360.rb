module ScraperStrategies
  class Fusion360 < Base

    private
      def after_parse
        tags = @parsed.css('.tags a, .project-header small')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')

        fragment = Nokogiri::XML::Node.new 'p', @article
        fragment.inner_html = "This project can be seen at <a href='#{@page_url}'>#{@page_url}</a>."
        @article.children.first.before fragment
      end

      def extract_cover_image
        @parsed.css('img').each do |img|
          src = get_src_for_img(img)
          return img if test_link src
        end
        nil
      end

      def extract_images base=@parsed, super_base=nil
        @parsed.css('#asset-placeholder .model-display a').reverse.each do |a|
          src = a['href']
          if test_link(src)
            img = Nokogiri::XML::Node.new 'img', @article
            img['src'] = src
            caption = a['title']
            img['title'] = caption if caption.present?
            @article.children.first.before img
          end
        end
      end

      def extract_title
        @parsed.at_css('.project-header h1').text.strip
      end

      def select_article
        @parsed.at_css('.project-description')
      end
  end
end