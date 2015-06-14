class Hashtag < ActiveRecord::Base
  has_and_belongs_to_many :channels
  has_and_belongs_to_many :thoughts

  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9]+\z/, message: "accepts only letters and numbers" }
end
