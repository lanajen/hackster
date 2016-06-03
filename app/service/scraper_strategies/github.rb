module ScraperStrategies
  class Github < Base

    private
      def before_parse
        github_link = "https://github.com#{@parsed.at_css('h1 strong a')['href']}"

        @project.one_liner = @parsed.at_css('.repository-description').try(:text).try(:strip).try(:truncate, 140)
        @project.website = @parsed.at_css('.repository-website').try(:text).try(:strip) || github_link

        @article.children.after "<iframe src='#{github_link}'></iframe>"
        super
      end

      def extract_title
        @parsed.at_css('h1 strong').text.strip
      end

      def parse_code
        # we don't want to create code widgets for code snippets on github
      end

      def select_article
        @parsed.at_css('article') || @parsed.at('#readme .plain') || @parsed.at('h1')
      end
  end
end