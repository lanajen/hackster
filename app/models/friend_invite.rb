class FriendInvite < ActiveRecord::Base
  has_many :users
  accepts_nested_attributes_for :users
  attr_accessible :users_attributes, :emails
  attr_accessor :emails
  validates :users, presence: true

  def has_invites?
    users.any?
  end

  def extract_emails
    self.users = emails.split(/\s+|,|;|(\r)?\n/).select do |email|
      email.present?
    end.map do |email|
      User.new email: email
    end
  end

  def enqueue_invites user
    MailerQueue.perform_async 'send_invites', users.map(&:email).join(','), user.id
  end

  def filter_blank_and_init!
    self.users = users.select do |user|
      unless user.email.blank?
        user.new_invitation = true
        user.skip_confirmation!
      end
    end
  end

  def invite_all! invited_by=nil
    existing_users = User.where(invitation_token: nil).where('users.email IN (?)', users.map(&:email)).pluck(:email)

    users.map(&:email).uniq.select do |email|
      User.invite!({ email: email }, invited_by) unless email.blank? or email.in? existing_users
    end#.map { |u| User.invite!({ email: u.email }, invited_by) }
  end

  def persisted?
    false
  end
end