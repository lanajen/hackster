class Member < ActiveRecord::Base
  include Roles
  set_roles :group_roles, %w(staff student professor)

  belongs_to :group
  belongs_to :invited_by, polymorphic: true
  belongs_to :permission, dependent: :destroy
  belongs_to :user
  attr_protected #none

  accepts_nested_attributes_for :permission, allow_destroy: true

  validates :user_id, uniqueness: { scope: :group_id }
  validates :mini_resume, length: { maximum: 250 }

  def self.invitation_accepted_or_not_invited
    where('members.invitation_sent_at IS NULL OR members.invitation_accepted_at IS NOT NULL')
  end

  def accept_invitation!
    update_attributes(invitation_accepted_at: Time.now) unless invitation_accepted_at.present?
  end

  def contribution
    mini_resume
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

  def label_method
    user.name
  end

  def permission_action=(val)
    self.permission.action = val
  end
end
