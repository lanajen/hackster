class ThreadPost < ActiveRecord::Base
  self.table_name = :threads

  belongs_to :user
  has_many :comments, -> { order created_at: :asc }, as: :commentable, dependent: :destroy
  # below is a hack because commenters try to add order by comments created_at and pgsql doesn't like it
  has_many :comments_copy, as: :commentable, dependent: :destroy, class_name: 'Comment'
  has_many :commenters, -> { uniq true }, through: :comments_copy, source: :user

  attr_accessible :body, :title

  validates :title, presence: true, length: { maximum: 255 }
end
