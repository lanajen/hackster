class ParticipantInvite < ActiveRecord::Base
  belongs_to :issue
  belongs_to :project
  belongs_to :user
  
  attr_accessible :email, :project_id, :user_id, :issue_id, :accepted
end
