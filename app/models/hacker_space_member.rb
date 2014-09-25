class HackerSpaceMember < Member
  set_roles :group_roles, %w(hacker)
  attr_protected #none

  def default_roles
    %w(hacker)
  end
end