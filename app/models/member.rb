class Member < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  attr_protected #none

  validates :user_id, uniqueness: { scope: :group_id }

  # attr_accessible :mini_resume, :group_roles, :title

  def method_missing method_name, *args
    if user
      user.send method_name, *args
    else
      super *args
    end
  end
end
