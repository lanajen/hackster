module ScraperStrategies
  class Littlebit < Base

    private
      def after_parse
        extract_components
        extract_code

        super
      end

      def before_parse
        tags = @parsed.css('.tag-list a')
        @project.product_tags_string = tags.map{|a| a.text }[0..2].join(',')

        @project.platform_tags_string = 'Littlebits'
        super
      end

      def extract_components
        parts = @parsed.css('.bits-list li')
        return unless parts.any?
        platform = Platform.find_by_user_name 'littlebits'

        parts.each_with_index do |comp, i|
          part = HardwarePart.new
          part.name = comp.at_css('.item-list-name').text.strip
          if store_link = comp.at_css('.item-list-name').try(:[], 'href')
            part.store_link = normalize_link store_link
          end
          part.platform = platform
          part.build_image
          part.image.remote_file_url = comp.at_css('img')['src']
          part.save

          part_join = PartJoin.new part_id: part.id, partable_id: 0,
            partable_type: 'BaseArticle'
          part_join.position = i + 1
          @parts << part_join
        end
      end

      def extract_code
        code = @parsed.at_css('.project-code tbody').try(:content)
        return unless code

        file = CodeWidget.new raw_code: code, name: 'Code', language: 'c_cpp'
        file.project = @project
        @widgets << file
      end

      def extract_title
        @parsed.at_css('h1').remove.text.strip
      end

      def select_article
        text = ''
        text += @parsed.css('#carousel-generic img').map{|i| i.to_html }.join('')
        text += @parsed.at_css('.project-description').try(:to_html)
        text += @parsed.at_css('.steps-list').try(:to_html)
        Nokogiri::HTML::DocumentFragment.parse(text)
      end
  end
end