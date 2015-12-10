class PlatformMember < Member
  set_roles :group_roles, %w(admin member moderator)
  attr_protected #none

  def self.conditional_group_roles platform
    _roles = {
      'Admin' => 'admin',
      'Member' => 'member',
    }
    _roles['Moderator'] = 'moderator' if platform.enable_moderators?
    _roles
  end

  def default_roles
    %w(admin)
  end
end