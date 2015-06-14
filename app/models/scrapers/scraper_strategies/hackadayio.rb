module ScraperStrategies
  class Hackadayio < Base

    private
      def after_parse
        extract_components
        extract_build_logs

        @article.css('h5').each{|el| el.name = 'h3' }
        super
      end

      def before_parse
        @project.one_liner = @parsed.at_css('.headline .description').try(:text).try(:strip).try(:truncate, 140)
        @project.product_tags_string = @parsed.css('.section-tags .tag:not(.tag-completed)').map{|a| a.text }.join(',')
        tags = @project.product_tags_string.split(',').map{|t| t.downcase }
        platforms = Platform.joins(:platform_tags).where("LOWER(tags.name) IN (?)", tags).distinct(:id)
        if platforms.any?
          @project.platforms = platforms
          @project.platform_tags_string = platforms.map{|t| t.name }.join(',')
        end
        prepare_images @article, @parsed

        super
      end

      def prepare_images base=@article, super_base=@parsed
        if super_base and super_base.at_css('.thumbs-holder')
          super_base.css('.thumbs-holder a').each do |img|
            src = img['data-image'].gsub(/resize\/[0-9x]+\//, '')
            if test_link(src)
              node = Nokogiri::XML::Node.new "img", base
              node['src'] = src
              parent = base.at_css('.section-description') || base.at_css('.section-details')
              parent.add_previous_sibling node
            end
          end
        end
      end

      def extract_build_logs
        parsed_logs = if @parsed.at_css('.section-buildlogs .log-btns a')
          content = fetch_page @host + @base_uri + '/logs'
          Nokogiri::HTML(content)
        else
          @parsed
        end

        logs = parsed_logs.css('.buillogs-list > li')
        return unless logs.any?

        logs.each do |log|
          post = @project.build_logs.new
          post.user_id = 0
          post.title = log.at_css('h2').text.strip
          post.body = log.at_css('[id^="post-body"]')
          @log = post.body
          parse_images @log, false
          parse_embeds @log
          parse_files @log
          parse_code @log
          clean_up_formatting '@log'
          post.body = @log.children.to_s
        end
      end

      def extract_cover_image
        @parsed.css('.thumbs-holder a').each do |img|
          src = img['data-image'].gsub(/resize\/[0-9x]+\//, '')
          if test_link(src)
            node = Nokogiri::XML::Node.new 'img', @parsed
            node['src'] = src
            return node
          end
        end
        nil
      end

      def extract_components
        parsed_components = if @parsed.at_css('.section-components a')
          content = fetch_page @host + @base_uri + '/components'
          Nokogiri::HTML(content)
        else
          @parsed
        end

        parts = parsed_components.css('.component-table-list tr, .section-component-list li')
        return unless parts.any?

        parts.each_with_index do |comp, i|
          part = Part.new
          comment = comp.at_css('.component-description').try(:text).try(:strip)
          part.name = comp.at_css('.component-name, .component-content').text.gsub(comment || '', '').strip
          part.save

          part_join = PartJoin.new part_id: part.id, partable_id: 0,
            partable_type: 'Project'
          part_join.quantity = comp.at_css('.quantity, .component-number').text.strip
          part_join.comment = comment
          part_join.position = i + 1
          @parts << part_join
        end
      end

      def extract_title
        @parsed.at_css('.headline h2').text.strip
      end

      def select_article
        text =  @parsed.at_css('.section-description').to_s + @parsed.at_css('.section-details').to_s + @parsed.css('.links-item a').map{|el| el.to_s }.join('<br>')

        if instructions = @parsed.at_css('.section-instructions')
          parsed_instructions = if instructions.at_css('a.show')
            content = fetch_page @host + @base_uri + '/instructions'
            Nokogiri::HTML(content)
          else
            instructions
          end
          text += '<h2>Build instructions</h2>'
          instructions.css('.instruction-list-item').each do |item|
            text += item.children.to_html
          end
        end

        Nokogiri::HTML::DocumentFragment.parse(text)
      end
  end
end