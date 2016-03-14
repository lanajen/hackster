class FriendInvite < ActiveRecord::Base
  has_many :users
  accepts_nested_attributes_for :users
  attr_accessible :users_attributes, :emails, :message
  attr_accessor :emails, :message
  validates :users, presence: true

  before_validation :newlines_to_br_for_message

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
    MailerQueue.perform_async 'send_invites', users.map(&:email).join(','), user.id, message
  end

  def filter_blank_and_init!
    self.users = users.select do |user|
      unless user.email.blank?
        user.new_invitation = true
        user.skip_email_confirmation!
        user.skip_welcome_email!
      end
    end
  end

  def invite_all! invited_by=nil
    existing_users = User.where(invitation_token: nil).where('users.email IN (?)', users.map(&:email)).pluck(:email)

    users.map(&:email).uniq.select do |email|
      unless email.blank? or email.in? existing_users
        user = User.invite!({ email: email }, invited_by) do |u|
          u.skip_invitation = true
        end
        user.deliver_invitation_with({ personal_message: message })
      end
    end
  end

  def persisted?
    false
  end

  private
    def newlines_to_br_for_message
      self.message = message.strip.gsub(/\r\n/, '<br>')
    end
end