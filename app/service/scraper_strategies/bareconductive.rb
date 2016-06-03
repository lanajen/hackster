module ScraperStrategies
  class Bareconductive < Base

    private
      def after_parse
        extract_components

        super
      end

      def before_parse
        @project.one_liner = @parsed.at_css('.make-subtitle').try(:text).try(:strip).try(:truncate, 140)

        super
      end

      def extract_cover_image
        @parsed.at_css('#main img')
      end

      def extract_components
        parts = @parsed.css('.product-sidebar .contain')
        return unless parts and parts.any?

        bareconductive_platform = Platform.find_by_user_name('bareconductive')
        parts.each_with_index do |comp, i|
          part = HardwarePart.new
          part.name = comp.at_css('.product-title .title').text.strip
          part.store_link = comp.at_css('.product-link')['href']
          part.platform = bareconductive_platform
          part.save

          part_join = PartJoin.new part_id: part.id, partable_id: 0,
            partable_type: 'BaseArticle'
          part_join.position = i + 1
          @parts << part_join
        end
      end

      def extract_title
        @parsed.at_css('h1').text.strip
      end

      def select_article
        text = @parsed.at_css('#tab-1').to_s
        text += @parsed.at_css('#make-content-blocks').to_s
        article = Nokogiri::HTML::DocumentFragment.parse(text)
        article.css('h4.thin').each do |node|
          node.previous.remove if node.previous and node.previous.class == Nokogiri::XML::Text
          if prev = node.previous and prev.name == 'h4'
            prev.content = prev.text + ': ' + node.text
            node.remove
          end
        end
        article
      end
  end
end