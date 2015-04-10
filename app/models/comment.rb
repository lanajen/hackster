class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :parent, class_name: 'Comment'
  belongs_to :user
  has_many :likes, as: :respectable, class_name: 'Respect', dependent: :destroy
  has_many :liking_users, class_name: 'User', through: :likes, source: :user

  attr_accessor :children, :depth
  attr_accessible :raw_body, :user_attributes, :parent_id, :guest_name

  validates :raw_body, presence: true

  accepts_nested_attributes_for :user

  before_save :parse_body, if: proc{|c| c.raw_body_changed?}
  # sanitize_text :body
  # register_sanitizer :newlines_to_br, :before_save, :body
  register_sanitizer :responsive_images, :before_save, :body

  def self.by_commentable_type type
    joins("JOIN #{type.table_name} ON #{type.table_name}.id = #{self.table_name}.commentable_id AND #{self.table_name}.commentable_type = '#{type.to_s}'")
  end

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
    return sorted unless parents[nil]

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

    def parse_body
      return unless raw_body

      markdown = Redcarpet::Markdown.new(Redcarpet::Render::CustomRenderer, Redcarpet::MARKDOWN_FILTERS)
      self.body = markdown.render(raw_body)
    end

    # def newlines_to_br text
    #   text.strip.gsub(/\r\n/, '<br>')
    # end

    def responsive_images text
      xml = Nokogiri::HTML::DocumentFragment.parse text
      xml.css('img').each do |img|
        img['class'] = 'img-responsive'
      end
      xml.to_html
    end
end
