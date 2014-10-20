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
        teches = Tech.joins(:tech_tags).where("LOWER(tags.name) IN (?)", tags).distinct(:id)
        if teches.any?
          @project.teches = teches
          @project.tech_tags_string = teches.map{|t| t.name }.join(',')
        end

        super
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
          post = @project.blog_posts.new
          post.user_id = 0
          post.title = log.at_css('h2').text.strip
          post.body = log.at_css('[id^="post-body"]')
          @log = post.body
          parse_images @log
          parse_embeds @log
          parse_files @log
          parse_code @log
          clean_up_formatting @log
          post.body = @log.children.to_s
        end
      end

      def extract_cover_image
        @parsed.css('.thumbs-holder a').each do |img|
          src = img['href']
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

        widget = PartsWidget.new
        widget.widgetable_id = 0
        parts.each_with_index do |comp, i|
          part = widget.parts.new
          part.quantity = comp.at_css('.quantity, .component-number').text.strip
          part.comment = comp.at_css('.component-description').try(:text).try(:strip)
          part.description = comp.at_css('.component-name, .component-content').text.gsub(part.comment || '', '').strip
          part.position = i + 1
        end
        widget.save
        @widgets << widget
        @article.children.last.after "<div class='embed-frame' data-widget-id='#{widget.id}' data-type='widget'></div>"
      end

      def extract_images base=@article, super_base=@parsed
        if super_base and super_base.at_css('.thumbs-holder')
          super_base.css('.thumbs-holder a').each do |img|
            src = img['href']
            if test_link(src)
              node = Nokogiri::XML::Node.new "img", base
              node['src'] = src
              parent = base.css('img').last || base.at_css('.section-description')
              parent.add_next_sibling node
            end
          end
        else
          super base
        end

        # raise base.to_s
      end

      def extract_title
        @parsed.at_css('.headline h2').text.strip
      end

      def select_article
        text =  @parsed.at_css('.section-description').to_s + @parsed.at_css('.section-details').to_s + @parsed.css('.links-item a').map{|el| el.to_s }.join('<br>')
        Nokogiri::HTML::DocumentFragment.parse(text)
      end
  end
end