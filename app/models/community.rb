class Community < Group
  include Privatable

  has_many :granted_permissions, as: :grantee, class_name: 'Permission'
  has_many :projects, through: :granted_permissions, source: :permissible,
    source_type: 'Project'
  validates :user_name, :full_name, presence: true
  validates :user_name, uniqueness: { scope: [:type, :parent_id] }
  before_create :generate_user_name

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

  def generate_user_name
    slug = name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase

    # make sure it doesn't exist
    if result = self.class.where(user_name: slug).first
      return if self == result
      # if it exists add a 1 and increment it if necessary
      slug += '1'
      while self.class.where(user_name: slug).first
        slug.gsub!(/([0-9]+$)/, ($1.to_i + 1).to_s)
      end
    end
    self.user_name = slug
  end
end