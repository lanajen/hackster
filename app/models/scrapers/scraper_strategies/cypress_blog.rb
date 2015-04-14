module ScraperStrategies
  class CypressBlog < Base
    private
      def before_parse
        @article.css('table').last.remove
        title = @article.at_css('.BlogPostTitle')
        title.parent.next.remove

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