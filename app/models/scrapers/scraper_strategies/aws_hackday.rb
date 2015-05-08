module ScraperStrategies
  class AwsHackday < Base

    private
      def before_parse
        @article.css('[id^="next-steps"]').each{|el| el.remove }
        @article.css('h1 a, h2 a').each{|el| el.remove }

        super
      end

      def select_article
        text = @parsed.at_css('.body').to_s

        next_links = []
        next_link = @parsed.at_css('.breadcrumb li:last-child a').try(:[], 'href')
        next_link = normalize_link(next_link)
        current_link = @page_url

        while scrape_next_page?(current_link, next_link, next_links)
          puts "Extracting subpage #{next_link}"
          next_links << next_link
          current_link = next_link

          content = fetch_page current_link
          doc = Nokogiri::HTML(content)
          @page = doc.at_css('.body')
          normalize_links doc
          text += @page.to_s
          next_link = doc.at_css('.breadcrumb li:last-child a').try(:[], 'href')
        end

        Nokogiri::HTML::DocumentFragment.parse(text)
      end

      def scrape_next_page? current_link, next_link, previous_links
        next_link.present? and !next_link.in?(previous_links) and URI(current_link).path.split('-').first == URI(next_link).path.split('-').first
      end

      def title_levels
        1..2
      end
  end
end