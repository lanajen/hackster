class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :parent, class_name: 'Comment'
  belongs_to :user

  attr_accessor :children, :depth
  attr_accessible :body, :user_attributes, :parent_id, :guest_name

  validates :body, presence: true

  accepts_nested_attributes_for :user

  sanitize_text :body
  register_sanitizer :newlines_to_br, :before_save, :body
  register_sanitizer :responsive_images, :before_save, :body

  def self.sort_from_hierarchy comments
    parents = {}
    comments.each do |comment|
      if comment.parent.in? parents.keys
        parents[comment.parent] << comment
      else
        parents[comment.parent] = [comment]
      end
    end

    sorted = []
    parents[nil].each do |child|
      child.depth = 0
      if child.in? parents.keys
        child = make_hierachy parents[child], parents, child
      end

      sorted << child
    end
  end

  def disable_notification!
    @disable_notification = true
  end

  def disable_notification?
    @disable_notification
  end

  def to_tracker
    {
      comment_size: body.length,
      comment_id: id,
      commentable_id: commentable_id,
      commentable_type: commentable_type,
    }
  end

  private
    def self.make_hierachy children, parents, parent, depth=0
      depth += 1
      children.each do |child|
        child.depth = depth
        if child.in? parents.keys
          child = make_hierachy parents[child], parents, child, depth
        end

        if parent.children
          parent.children << child
        else
          parent.children = [child]
        end
      end
      parent
    end

    def newlines_to_br text
      text.strip.gsub(/\r\n/, '<br>')
    end

    def responsive_images text
      xml = Nokogiri::HTML text
      xml = xml.at_css('body').children
      xml.search('img').each do |img|
        img['class'] = 'img-responsive'
      end
      xml.to_html
    end
end
