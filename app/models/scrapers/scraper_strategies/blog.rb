module ScraperStrategies
  class Blog < Base

    private
      def before_parse
        tags = @parsed.css('[rel=category]') + @parsed.css('[rel=tag]') + @parsed.css('[rel="category tag"]')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')
        @article.css('.post-meta').each{|el| el.remove }

        super
      end

      def extract_title
        @article.at_css('.entry-title').try(:remove).try(:text).try(:strip) || @article.at_css('h1').try(:remove).try(:text).try(:strip) || @parsed.title
      end

      def select_article
        @parsed.at_css('article') || @parsed.at('.entry') || @parsed.at_css('.post') || @parsed.at('body')
      end
  end
end