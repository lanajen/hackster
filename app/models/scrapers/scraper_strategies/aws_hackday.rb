module ScraperStrategies
  class AwsHackday < Base

    private
      def before_parse
        @article.css('[id^="next-steps"]').each{|el| el.remove }
        @article.css('h1 a, h2 a').each{|el| el.remove }

        super
      end

      def select_article
        text = @parsed.at_css('#main-col-body').to_s

        next_links = []
        next_link = @parsed.css('#next a').last.try(:[], 'href')
        next_link = normalize_link(next_link)
        current_link = @page_url

        while scrape_next_page?(current_link, next_link, next_links)
          puts "Extracting subpage #{next_link}"
          next_links << next_link
          current_link = next_link

          content = fetch_page current_link
          doc = Nokogiri::HTML(content)
          @page = doc.at_css('#main-col-body')
          normalize_links doc
          text += @page.to_s
          next_link = doc.css('#next a').last.try(:[], 'href')
        end

        Nokogiri::HTML::DocumentFragment.parse(text)
      end

      def scrape_next_page? current_link, next_link, previous_links
        next_link.present? and !next_link.in?(previous_links)
      end

      def title_levels
        1..2
      end
  end
end