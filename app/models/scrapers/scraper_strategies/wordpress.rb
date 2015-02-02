module ScraperStrategies
  class Wordpress < GenericBlog

    def crap_list
      super + %w(.share-post .wpcnt .post-info)
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
          body = comment.at_css('.comment-content').try(:inner_html) || comment.at_css('.comment-body').try(:inner_html)
          name = comment.at_css('.comment-author .fn').try(:text).try(:strip)
          next unless body and name
          datetime = comment.at_css('time').try(:[], 'datetime')
          created_at = DateTime.parse datetime if datetime
          c = @project.comments.new body: body, guest_name: name
          c.created_at = created_at
          c.parent = parent
          c.disable_notification!
          _parse_comments comment, depth+1, c
        end
      end
  end
end