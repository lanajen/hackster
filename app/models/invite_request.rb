class InviteRequest < ActiveRecord::Base
  belongs_to :user

  attr_accessible :email, :whitelisted

  validates :email, presence: true
  validates :email, uniqueness: { message: 'has already requested an invite' }
  validates :email, format: { with: /^\b[a-z0-9._%-]+@[a-z0-9.-]+\.[a-z]{2,4}\b$/, message: 'is not a valid email address'}

  def self.email_whitelisted? email
    where(email: email, whitelisted: true).size > 0
  end
end
