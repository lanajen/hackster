class InviteRequest < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  attr_accessible :email, :whitelisted, :project_attributes

  accepts_nested_attributes_for :project

  validates :email, presence: true
  validates :email, uniqueness: { message: 'has already requested an invite' }
  validates :email, format: { with: /^\b[a-z0-9._%-\+]+@[a-z0-9.-]+\.[a-z]{2,4}(\.[a-z]{2,4})?\b$/, message: 'is not a valid email address'}

  self.per_page = 20

  def self.email_whitelisted? email
    where(email: email, whitelisted: true).size > 0
  end

  def self.send_invite_to_all!
    self.where(whitelisted: false).each do |invite|
      invite.send_invite!
    end
  end

  def security_token
    Digest::MD5.hexdigest(email)
  end

  def send_invite!
    update_attribute(:whitelisted, true) if User.invite!(email: email)
  end

  def to_param
    "#{id}-#{security_token}"
  end

  def to_tracker
    {
      created: created_at,
      email: email,
    }
  end

  def security_token_valid? token
    token.match(/[0-9]+\-(.*)/)[1] == security_token
  end
end
