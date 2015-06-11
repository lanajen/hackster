module ScraperStrategies
  class Blogspot < GenericBlog

    private
      def crap_list
        super + %w(.blogadmin .postfooter .post-footer)
      end

      def parse_comments
        if dom = extract_comments
          authors = dom.css('.commentauthor, .comment-author');
          bodies = dom.css('.commentbody, .comment-body');
          footers = dom.css('.commentfooter, .comment-footer');

          authors.each_with_index do |author, i|
            name = author.text.gsub(/said\.\.\./, '').strip
            body = bodies[i].inner_html
            created_at = DateTime.parse footers[i].text.strip
            c = @project.comments.new raw_body: body, guest_name: name
            c.created_at = created_at
            c.disable_notification!
          end
        end
      end
  end
end