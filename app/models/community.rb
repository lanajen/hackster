class Community < Group
  include Privatable

  has_many :projects, through: :permissions, source: :permissible,
    source_type: 'Project'
  validates :user_name, :full_name, presence: true

  def self.model_name
    Group.model_name
  end

  def invite_with_emails emails, invited_by=nil
    emails = emails.gsub(/\r\n/, ',').gsub(/\n/, ',').gsub(/[ ]+/, ',').split(',').reject{ |l| l.blank? }
    emails.each do |email|
      invite_with_email email, invited_by
    end
  end

  def invite_with_email email, invited_by=nil
    unless user = User.find_by_email(email)
      user = User.invite!({ email: email }, invited_by) do |u|
        u.skip_invitation = true
      end
    end
    member = members.create user_id: user.id, invitation_sent_at: Time.now, invited_by: invited_by
    user.deliver_invitation_with member if member.persisted? and user.invited_to_sign_up?
  end
end