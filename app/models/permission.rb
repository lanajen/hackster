class Permission < ActiveRecord::Base
  ACTIONS = {
    'Manage' => 'manage',
    'Read' => 'read',
  }

  belongs_to :grantee, polymorphic: true
  belongs_to :permissible, polymorphic: true
  has_one :group, through: :member
  has_one :member

  before_create :set_action
  validates :grantee_id, uniqueness: { scope: [:grantee_type, :permissible_id, :permissible_type] }

  attr_accessible :grantee_type, :grantee_id, :action

  def users
    return [] unless grantee_type.present?

    grantee_type == 'User' ? [grantee] : grantee.users
  end

  private
    def set_action  # default
      self.action = 'read' if action.blank?
    end
end
