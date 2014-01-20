module ScraperStrategies
  class Blog < Base

    private
      def initialize_scrapping &block
        puts 'Converting to project...'

        @project = Project.new private: true
        @widgets = []

        @article = @parsed.at_css('article') || @parsed.at_css('.post') || @parsed

        @project.name = @article.at_css('.entry-title').try(:remove).try(:text) || @article.css('h1').last.try(:remove).try(:text) || @article.at_css('h2').try(:remove).try(:text) || @parsed.title

        tags = @article.css('[rel=category]') + @article.css('[rel=tag]') + @article.css('[rel="category tag"]')
        @project.product_tags_string = tags.map{|a| a.text }.join(',')

        yield if block_given?

        parse_links
        parse_images
      end
  end
end