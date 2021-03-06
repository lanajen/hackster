class Comment < ActiveRecord::Base
  include Notifiable

  belongs_to :commentable, polymorphic: true
  belongs_to :parent, class_name: 'Comment'
  belongs_to :user
  has_many :likes, as: :respectable, class_name: 'Respect', dependent: :destroy
  has_many :liking_users, class_name: 'User', through: :likes, source: :user
  has_many :notifications, as: :notifiable, dependent: :delete_all
  has_many :receipts, as: :receivable, dependent: :destroy
  has_many :reputation_events, as: :event_model, dependent: :delete_all

  attr_accessor :children, :depth
  attr_accessible :raw_body, :user_attributes, :parent_id, :guest_name

  validates :raw_body, presence: true

  accepts_nested_attributes_for :user

  before_save :generate_hid, if: proc{|c| c.hid.blank? }
  before_save :parse_body, if: proc{|c| c.raw_body_changed?}
  # sanitize_text :body
  # register_sanitizer :newlines_to_br, :before_save, :body
  register_sanitizer :responsive_images, :before_save, :body

  def self.by_commentable_type type
    joins("JOIN #{type.table_name} ON #{type.table_name}.id = #{self.table_name}.commentable_id AND #{self.table_name}.commentable_type = '#{type.to_s}'")
  end

  def self.cache_key commentable_type, commentable_id
    [commentable_type.underscore, commentable_id, 'comments'].join('/')
  end

  def self.have_owner
    where.not(user_id: 0)
  end

  def self.live
    where(deleted: false)
  end

  def self.sort_from_hierarchy comments
    parents = {}
    comments.each do |comment|
      if comment.parent_id.in? parents.keys
        parents[comment.parent_id] << comment
      else
        parents[comment.parent_id] = [comment]
      end
    end

    sorted = []
    return sorted unless parents[nil]

    parents[nil].each do |child|
      child.depth = 0
      if child.id.in? parents.keys
        child = make_hierachy parents[child.id], parents, child
      end

      sorted << child
    end

    sorted
  end

  def association_name_for_notifications
    commentable_type
  end

  def by_guest?
    user_id.nil? or user_id == 0
  end

  def children force=false
    if force
      @children = Comment.where(parent_id: id)
    else
      @children
    end
  end

  # soft destroy
  def destroy
    if is_root? and children(true).exists?
      update_attribute :deleted, true
    else
      super
    end
  end

  def disable_notification!
    @disable_notification = true
  end

  def disable_notification?
    @disable_notification
  end

  def has_parent?
    parent_id.present?
  end

  def is_root?
    parent_id.nil?
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
        if child.id.in? parents.keys
          child = make_hierachy parents[child.id], parents, child, depth
        end

        if parent.children
          parent.children << child
        else
          parent.children = [child]
        end
      end
      parent
    end

    def generate_hid
      loop do
        hid = Devise.friendly_token.downcase.gsub(/[^a-z0-9]/, '')[0..15]
        unless Comment.where(hid: hid).exists?
          self.hid = hid
          break
        end
      end
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
