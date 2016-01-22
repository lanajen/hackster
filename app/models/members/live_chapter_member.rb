class LiveChapterMember < Member
  set_roles :group_roles, %w(participant organizer)
  attr_protected #none

  def default_roles
    %w(participant)
  end
end