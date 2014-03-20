class PromotionMember < Member
  set_roles :group_roles, %w(ta student professor)
  attr_protected #none

  def default_roles
    %w(student)
  end
end