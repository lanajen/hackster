class Member < ActiveRecord::Base
  belongs_to :group
  belongs_to :invited_by, polymorphic: true
  belongs_to :permission, dependent: :destroy
  belongs_to :user
  attr_protected #none

  accepts_nested_attributes_for :permission, allow_destroy: true

  validates :user_id, uniqueness: { scope: :group_id }

  def self.invitation_accepted_or_not_invited
    where('members.invitation_sent_at IS NULL OR members.invitation_accepted_at IS NOT NULL')
  end

  def accept_invitation!
    update_attributes(invitation_accepted_at: Time.now) unless invitation_accepted_at.present?
  end

  def initialize_permission save=false
    perm = permission || build_permission
    perm.grantee = user unless perm.grantee
    perm.permissible = group unless perm.permissible
    perm.action = group.class.default_permission if group and !perm.action
    perm.save if save
    self.permission = perm
  end

  def invitation_pending?
    invitation_sent_at.present? and invitation_accepted_at.nil?
  end

  def joined_at
    invitation_accepted_at || created_at
  end

  def permission_action=(val)
    self.permission.action = val
  end

  # attr_accessible :mini_resume, :group_roles, :title

  # this somewhat fails when creating a new team member for a project
  # def method_missing method_name, *args
  #   if user
  #     user.send method_name, *args
  #   else
  #     super *args
  #   end
  # end
end
