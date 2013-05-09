class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  attr_accessible :body

  validates :body, :user_id, :commentable_type, :commentable_id, presence: true

  sanitize_text :body
  newlines_to_html_text :body
end
