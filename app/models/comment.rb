class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  attr_accessible :body

  validates :body, :user_id, :commentable_type, :commentable_id, presence: true

  sanitize_text :body
  register_sanitizer :newlines_to_br, :before_save, :body

  private
    def newlines_to_br text
      text.strip.gsub(/\r\n/, '<br>')
    end
end
