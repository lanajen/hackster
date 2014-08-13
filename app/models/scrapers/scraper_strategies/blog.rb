module ScraperStrategies
  class Blog < Base

    private
      def before_parse
        tags = @article.css('[rel=category]') + @article.css('[rel=tag]') + @article.css('[rel="category tag"]')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')

        super
      end

      def extract_title
        @article.at_css('.entry-title').try(:remove).try(:text) || @article.css('h1').last.try(:remove).try(:text) || @article.at_css('h2').try(:remove).try(:text) || @parsed.title
      end

      def select_article
        @parsed.at_css('article') || @parsed.at_css('.post') || @parsed.at('body')
      end
  end
end