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
        prepare_images @article, @parsed

        super
      end

      def prepare_images base=@article, super_base=@parsed
        if super_base
          if super_base.at_css('.thumbs-holder')
            super_base.css('.thumbs-holder a').each do |img|
              prepare_image img, base
            end
          elsif img = super_base.at_css('#project-image')
            prepare_image img, base
          end
        end
      end

      def prepare_image img, base
        src = img['data-image'].gsub(/resize\/[0-9x]+\//, '')
        if test_link(src)
          node = Nokogiri::XML::Node.new "img", base
          node['src'] = src
          parent = base.at_css('.section-description') || base.at_css('.section-details')
          parent.add_previous_sibling node
        end
      end

      def extract_build_logs
        parsed_logs = if @parsed.at_css('.section-buildlogs .log-btns a')
          content = fetch_page @host + @base_uri + '/logs'
          Nokogiri::HTML(content)
        end

        logs = parsed_logs.css('.buildlogs-list > li')
        return unless logs.any?

        logs.each do |log|
          post = @project.build_logs.new
          post.user_id = 0
          post.title = log.at_css('h3').text.strip
          @log = log.at_css('[id^="post-body"]')
          post.body = @log
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
          part = HardwarePart.new
          comment = comp.at_css('.component-description').try(:text).try(:strip)
          part.name = comp.at_css('.component-name, .component-content').text.gsub(comment || '', '').strip
          part.save

          part_join = PartJoin.new part_id: part.id, partable_id: 0,
            partable_type: 'BaseArticle'
          part_join.quantity = comp.at_css('.quantity, .component-number').text.strip
          part_join.comment = comment
          part_join.position = i + 1
          @parts << part_join
        end
      end

      def extract_title
        @parsed.at_css('h1').text.strip
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
          parsed_instructions.css('.instruction-list-item').each_with_index do |item, i|
            text += "<p><strong>Step #{i+1}</strong></p>"
            text += item.children.to_html
          end
        end

        if @parsed.at_css('.section-files')
          text += '<h2>Files</h2>'
          @parsed.css('.section-files .file-details').each do |file|
            text += '<p>' + file.at_css('.description a').to_html
            if desc = file.at_css('.description span').try(:to_html)
              text += ': ' + desc
            end
            text += '</p>'
          end
        end

        Nokogiri::HTML::DocumentFragment.parse(text)
      end
  end
end