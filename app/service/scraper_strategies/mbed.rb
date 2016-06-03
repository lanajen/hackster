module ScraperStrategies
  class Mbed < Base

    private
      def before_parse
        tags = @parsed.css('.sidebar a[href^="/search/?q"]')
        @project.product_tags_string = tags.map{|a| a.text }.inject([]){|memo,tag| memo << tag if (memo.join(',').size + tag.size + 1) <= 140; memo }.join(',')
        @project.one_liner = @parsed.at_css('.sidebar p').try(:text).try(:strip).try(:truncate, 140)
        @article.css('.flashbox.flibrary, .flashbox.fprogram').each do |node|
          link = node.at_css('a:not(.button)')
          node.add_next_sibling "<p><a href='#{link['href']}'>#{link.text.strip}</a>: #{node.at_css('p').text.strip}</p>"
          node.remove
        end

        super
      end

      def format_text base=@article
        base.css('.flashbox.fwarning, .flashbox.finfo').each do |node|
          node.name = 'blockquote'
          node['class'] = nil
        end

        super
      end

      def crap_list
        super + %w(.flashbox.action-bar .wiki_permalink)
      end

      def extract_code_blocks base=@article
        base.css('.mbed-code')
      end

      def extract_code_lines node
        return node.content, 'c_cpp'
      end

      def extract_title
        @parsed.at_css('#mbed-content h2.over-cinfo').try(:text).try(:strip) || @parsed.at_css('#mbed-content h2').text.strip
      end

      def select_article
        @parsed.at_css('#mbed-content .wiki-content') || @parsed.at_css('#mbed-content')
      end
  end
end