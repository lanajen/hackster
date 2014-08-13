module ScraperStrategies
  class Wordpress < Blog

    def crap_list
      super + %w(.share-post)
    end

    def extract_cover_image
      @article.at_css('.single-post-thumb img') || @article.at_css('img')
    end

    def image_caption_container_classes
      super + %w(wp-caption single-post-thumb)
    end

    def image_caption_elements
      super + %w(.wp-caption-text .single-post-caption)
    end

    private
      def parse_comments
        if comment_dom = extract_comments
          depth = 1
          _parse_comments comment_dom
        end
      end

      def _parse_comments dom, depth=1, parent=nil
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
  end
end