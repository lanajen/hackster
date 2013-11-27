class TeamMember < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  attr_protected #none

  validates :user_id, uniqueness: { scope: :project_id }

#  delegate :name, :mini_resume, :user_name, to: :user

  # this somewhat fails when creating a new team member for a project
  # def method_missing method_name, *args
  #   if user
  #     user.send method_name, *args
  #   else
  #     super *args
  #   end
  # end
end
