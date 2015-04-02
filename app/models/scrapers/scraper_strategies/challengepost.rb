module ScraperStrategies
  class Challengepost < Base

    private
      def before_parse
        tags = @parsed.css('#built-with li')
        @project.platform_tags_string = tags.map{|a| a.text.gsub('-', ' ').titleize }.join(',')
        @article.at_css('#built-with').remove

        @project.one_liner = @parsed.at_css('#app-tagline').try(:text).try(:strip).try(:truncate, 140)
        super
      end

      def extract_title
        @parsed.at_css('#app-title').text.strip
      end

      def select_article
        article = @parsed.at_css('#app-details-left')
        gallery = article.at_css('#gallery')
        gallery.css('img, iframe').reverse.each{|m| article.children.first.add_previous_sibling(m) }
        gallery.remove
        # Nokogiri::HTML::DocumentFragment.parse(article.to_html)
        article
      end
  end
end