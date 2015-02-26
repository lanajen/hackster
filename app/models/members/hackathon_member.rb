class HackathonMember < Member
  set_roles :group_roles, %w(organizer)
  attr_protected #none

  def default_roles
    %w(organizer)
  end
end