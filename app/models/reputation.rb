class Reputation < ActiveRecord::Base
  belongs_to :user

  attr_accessible :points, :user_id
  validates :points, numericality: { only_integer: true }
  validates :points, :user_id, presence: true
end
