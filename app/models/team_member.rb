class TeamMember < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  attr_protected #none

  def method_missing method_name, *args
    if user
      user.send method_name, *args
    else
      super *args
    end
  end
end
