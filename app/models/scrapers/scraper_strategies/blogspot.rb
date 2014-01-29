module ScraperStrategies
  class Blogspot < Blog
    def to_project
      initialize_scrapping do
        @article.css('.blog-admin').find_all.each{|el| el.remove }
      end

      @article.css('.post-footer').find_all.each{|el| el.remove }
      parse_text

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
            name = author.text.gsub(/said\.\.\./, '').strip
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