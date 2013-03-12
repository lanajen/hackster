class Website < ActiveRecord::Base
  belongs_to :user

  attr_accessible :url
  validates :url, :user_id, presence: true
end
