class ThreadPost < ActiveRecord::Base
  self.table_name = :threads

  belongs_to :threadable, polymorphic: true
  belongs_to :user
  has_many :comments, -> { order created_at: :asc }, as: :commentable, dependent: :destroy
  has_many :commenters, -> { uniq true }, through: :comments, source: :user

  attr_accessible :body, :private, :title

  # validates :title, :body, presence: true
end
