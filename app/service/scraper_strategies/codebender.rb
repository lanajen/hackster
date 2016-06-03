module ScraperStrategies
  class Codebender < Base

    private
      def after_parse
        @widgets << CodeRepoWidget.new(url: @page_url, name: 'Code on codebender.cc', comment: @page_url)
        @project.one_liner = @parsed.at_css('#short-description').try(:text).try(:strip)

        super
      end

      def extract_title
        @parsed.at_css('h1 .sketch-name').text.strip
      end

      def select_article
        if @parsed.at_css('#description').text.present?
          @parsed.at_css('#description')
        else
          @parsed.at_css('#short-description')
        end
      end
  end
end