module ScraperStrategies
  class Blogspot < Blog

    private
      def before_parse
        @article.css('.blogadmin, .postfooter').find_all.each{|el| el.remove }
        super
      end

      def parse_comments
        if dom = @parsed.at_css('#comments')
          authors = dom.css('.commentauthor');
          bodies = dom.css('.commentbody');
          footers = dom.css('.commentfooter');

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