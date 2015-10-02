module ScraperStrategies
  class Instructable < Base

    private
      def after_parse
        tags = @parsed.css('.ible-tags a')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')

        if attachments = @parsed.css('#attachments') and attachments.any?
          files = []
          attachments.each do |attachment|
            attachments.css('a').each do |node|
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
                @article.add_child "<div class='embed-frame' data-file-id='#{document.id}' data-type='file'></div>"
              end
            end
          end
        end

        # parse_comments
        super
      end

      def before_parse
        @article.css('.lazyphoto').each{|n| n.remove }
        @article.css('.photoset-photo').each do |img|
          while img.parent.name != 'a'
            img.parent.parent.add_child img
          end
        end
        @article.css('br').each{|el| el.remove }

        super
      end

      def extract_images base=@article, super_base=nil
        base.css('.photoset-link').reverse.each do |img|
          until img.parent['class'] == 'photoset'
            img.parent.parent.add_child img
          end
        end

        super base, super_base
      end

      def crap_list
        super + %w(.inline-ads .photoset-seemore #attachments .photoset-showmore)
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