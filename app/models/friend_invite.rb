class FriendInvite < ActiveRecord::Base
  has_many :users
  accepts_nested_attributes_for :users
  attr_accessible :users_attributes
  validates :users, presence: true

  def has_invites?
    users.any?
  end

  def filter_blank_and_init!
    users.select! do |user|
      unless user.email.blank?
        user.new_invitation = true
        user.skip_confirmation!
      end
    end
  end

  def invite_all! invited_by=nil
    existing_users = User.where('users.email IN (?)', users.map(&:email)).each{ |u| u.invite!(invited_by) }.map(&:email)

    users.select! do |user|
      user.invite!(invited_by) unless user.email.blank? or user.email.in? existing_users
    end
  end

  def persisted?
    false
  end
end