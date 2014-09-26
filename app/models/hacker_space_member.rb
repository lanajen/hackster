class HackerSpaceMember < Member
  set_roles :group_roles, %w(member visitor team)
  attr_protected #none

  def default_roles
    %w(member)
  end
end