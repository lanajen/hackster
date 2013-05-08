class AccessGroupMember < ActiveRecord::Base
  belongs_to :access_group
  belongs_to :user

  attr_accessible :user_id
end
