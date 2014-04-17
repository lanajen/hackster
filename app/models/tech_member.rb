class TechMember < Member
  set_roles :group_roles, %w(admin member)
  attr_protected #none

  def default_roles
    %w(member)
  end
end