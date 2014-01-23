module ScraperStrategies
  class Blogspot < Blog
    def to_project
      initialize_scrapping do
        @article.css('.blog-admin').find_all.each{|el| el.remove }
      end

      @article.css('.post-footer').find_all.each{|el| el.remove }
      raw_text = @article.inner_html
      sanitized_text = Sanitize.clean(raw_text, Sanitize::Config::BASIC)
      text = Nokogiri::HTML(sanitized_text)
      text.css('a').find_all.each{|el| el.remove if el.content.strip.blank? }
      text.css('div').find_all.each{|el| el.remove if el.content.strip.blank? }
      text = Sanitize.clean(text.to_html, Sanitize::Config::BASIC_BLANK)
      @widgets << TextWidget.new(content: text, name: 'About')

      distribute_widgets
      parse_comments

      @project
    end

    private
      def parse_comments
        if dom = @parsed.at_css('#comments')
          authors = dom.css('.comment-author');
          bodies = dom.css('.comment-body');
          footers = dom.css('.comment-footer');

          authors.each_with_index do |author, i|
            name = author.text.strip.gsub(/said\.\.\./, '')
            body = bodies[i].inner_html
            created_at = DateTime.parse footers[i].text.strip
            c = @project.comments.new body: body, guest_name: name
            c.created_at = created_at
            c.disable_notification!
          end
        end
      end
  end
end