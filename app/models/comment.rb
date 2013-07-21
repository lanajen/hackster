class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :user, class_name: 'Account'

  attr_accessible :body, :user_attributes

  validates :body, :commentable_type, :commentable_id, presence: true

  accepts_nested_attributes_for :user

  sanitize_text :body
  register_sanitizer :newlines_to_br, :before_save, :body

  private
    def newlines_to_br text
      text.strip.gsub(/\r\n/, '<br>')
    end
end
