class CommunityMember < Member
  set_roles :group_roles, %w(member)
  attr_protected #none

  def default_roles
    %w(member)
  end
end