module ScraperStrategies
  class Wordpress < Blog

    private
      def extract_comments dom, depth=1, parent=nil
        dom.css("li.depth-#{depth}").each do |comment|
          body = comment.at_css('.comment-content').inner_html
          name = comment.at_css('.comment-author .fn').text.try(:strip)
          created_at = DateTime.parse comment.at_css('time')['datetime']
          c = @project.comments.new body: body, guest_name: name
          c.created_at = created_at
          c.parent = parent
          c.disable_notification!
          extract_comments comment, depth+1, c
        end
      end

      def parse_comments
        if comment_dom = @parsed.at_css('#comments')
          depth = 1
          extract_comments comment_dom
        end
      end
  end
end