module ScraperStrategies
  class Instructable < Base

    private
      def after_parse
        tags = @parsed.css('#ible-tags a')
        @project.product_tags_string = tags.map{|a| a.text }[0..2].join(',')

        super
      end

      def before_parse
        @article.css('.photoset-link img').each do |img|
          img['src'] = img.parent['data-fancybox-href']
          img.parent.parent.add_child img
        end
        @article.css('.photoset-link').each{|el| el.remove }
        @article.css('br').each{|el| el.remove }

        if attachments = @article.css('#attachments, #rich-embed-files') and attachments.any?
          files = []
          attachments.each do |attachment|
            attachments.css('.file-info a').each do |node|
              next unless link = node['href']
              next if link.in? files
              files << link
              link = normalize_link link
              if link.match /\/\/.+\/.+\.([a-z0-9]{,5})$/
                next unless test_link(link)
                content = node.text
                title = (content != link) ? content : ''
                puts "Parsing file #{link}..."
                document = Document.new remote_file_url: link, title: title.truncate(255)
                document.attachable_id = 0
                document.attachable_type = 'Orphan'
                document.save
                document.attachable = @project
                node.parent.parent.add_previous_sibling "<div class='embed-frame' data-file-id='#{document.id}' data-type='file'></div>"
              end
            end
          end
        end

        super
      end

      def crap_list
        super + %w(.inline-ads .photoset-seemore #attachments .photoset-showmore #rich-embed-files noscript)
      end

      def extract_title
        @parsed.at_css('h1').remove.text.strip
      end

      def select_article
        steps = @parsed.css('#instructable-wrapper .step-container').map{|t| t.to_html}.join('')
        Nokogiri::HTML::DocumentFragment.parse(steps)
      end
  end
end