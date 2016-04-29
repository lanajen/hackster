class MeetupMember < Member
  set_roles :group_roles, %w(member organizer)
  attr_protected #none

  def default_roles
    %w(member)
  end
end