module ScraperStrategies
  class CypressBlog < Base
    private
      def before_parse
        @article.css('table').last.remove
        title = @article.at_css('.BlogPostTitle')
        title.parent.next.remove
        @project.one_liner = @article.at_css('p').text.strip
        if @project.one_liner =~ /In today.+ project,/
          @project.one_liner = @project.one_liner.split(/,/, 2)[1].strip.capitalize
        end
        @project.one_liner = @project.one_liner.truncate 140
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