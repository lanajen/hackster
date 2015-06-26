module ScraperStrategies
  class CypressBlog < Base
    private
      def before_parse
        @article.css('table').last.remove
        title = @article.at_css('.BlogPostTitle')
        title.parent.next.remove
        if p = (@article.at_css('p') || @article.at_css('div'))
          @project.one_liner = p.text.strip
          if @project.one_liner =~ /In today.+ project,/
            @project.one_liner = @project.one_liner.split(/,/, 2)[1].strip.capitalize
          end
          @project.one_liner = @project.one_liner.truncate 140
        end
        @project.platform_tags_string = 'Cypress PSoC'

        super
      end

      def crap_list
        super + %w(.BlogDate .BlogPostTitle)
      end

      def extract_title
        @parsed.at_css('.BlogPostTitle').text.strip
      end

      def select_article
        @parsed.at_css('.BoxContent')
      end
  end
end