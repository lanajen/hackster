class TechMember < Member
  set_roles :group_roles, %w(admin)
  attr_protected #none

  def default_roles
    %w(admin)
  end
end