class ThreadPost < ActiveRecord::Base
  self.table_name = :threads

  belongs_to :threadable, polymorphic: true
  belongs_to :user
  has_many :comments, as: :commentable

  attr_accessible :body, :private, :title

  validates :title, :body, presence: true
end
