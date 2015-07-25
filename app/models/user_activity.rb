class UserActivity < ActiveRecord::Base
  belongs_to :user

  attr_accessible :user_id, :event, :created_at, :ip
end
