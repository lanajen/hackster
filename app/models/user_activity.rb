class UserActivity < ActiveRecord::Base
  belongs_to :user

  attr_protected  # none
end
