module ScraperStrategies
  class GenericBlog < Base

    private
      def before_parse
        tags = @parsed.css('a[rel=category]') + @parsed.css('a[rel=tag]') + @parsed.css('a[rel="category tag"]')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')
        @article.css('.post-meta').each{|el| el.remove }

        super
      end

      def extract_title
        @article.at_css('.entry-title').try(:remove).try(:text).try(:strip) || @article.at_css('h1').try(:remove).try(:text).try(:strip) || @parsed.at_css('.entry-title').try(:remove).try(:text).try(:strip) || @parsed.at_css('h1').try(:remove).try(:text).try(:strip) || @parsed.title
      end

      def select_article
        @parsed.at_css('article') || @parsed.at('.entry') || @parsed.at('.entry-content') || @parsed.at_css('.post') || @parsed.at('body')
      end
  end
end