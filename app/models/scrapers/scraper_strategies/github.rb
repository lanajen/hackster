module ScraperStrategies
  class Github < Base

    private
      def before_parse
        @project.one_liner = @parsed.at_css('.repository-description').try(:text).try(:strip)
        @project.website = @parsed.at_css('.repository-website').try(:text).try(:strip)

        github_link = "https://github.com#{@parsed.at_css('h1 strong a')['href']}"
        @widgets << GithubWidget.new(repo: github_link, name: 'Github repo')
        super
      end

      def extract_title
        @parsed.at_css('h1 strong').text.strip
      end

      def parse_code
        # we don't want to create code widgets for code snippets on github
      end

      def select_article
        @parsed.at_css('article') || @parsed
      end
  end
end