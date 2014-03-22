class Community < Group
  include Privatable

  has_many :granted_permissions, as: :grantee, class_name: 'Permission'
  has_many :projects, through: :granted_permissions, source: :permissible,
    source_type: 'Project'
  validates :user_name, :full_name, presence: true
  validates :user_name, uniqueness: { scope: [:type, :parent_id] }
  validates :user_name, :new_user_name, length: { in: 3..100 }, if: proc{|t| t.persisted?}
  before_validation :generate_user_name, on: :create
  before_save :ensure_invitation_token

  def self.default_access_level
    'request'
  end

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