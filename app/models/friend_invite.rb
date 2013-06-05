class FriendInvite < ActiveRecord::Base
  has_many :users
  accepts_nested_attributes_for :users
  attr_accessible :users_attributes
  validates :users, presence: true
#  validate :has_invites?

  def has_invites?
    !self.users.empty?
  end

  def filter_blank_and_init!
    self.users.select! do |user|
      unless user.email.blank?
        user.new_invitation = true
        user.skip_confirmation!
      end
    end
  end

  def invite_all! invited_by=nil
    self.users.select do |user|
      unless user.email.blank?
        user.invite!(invited_by)
      end
    end
  end

  def persisted?
    false
  end
end