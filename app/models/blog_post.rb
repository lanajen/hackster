class BlogPost < ActiveRecord::Base
  belongs_to :bloggable, polymorphic: true
  belongs_to :user
  has_many :comments, as: :commentable

  attr_accessible :body, :private, :title

  validates :title, :body, presence: true
end
