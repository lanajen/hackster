class EventMember < Member
  set_roles :group_roles, %w(participant organizer judge mentor)
  attr_protected #none

  def default_roles
    %w(participant)
  end
end