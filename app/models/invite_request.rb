class InviteRequest < ActiveRecord::Base
  attr_accessible :email

  validates :email, :presence => true
  validates :email, :uniqueness => { :message => 'has already requested an invite' }
  validates :email, :format => { :with => /^\b[a-z0-9._%-]+@[a-z0-9.-]+\.[a-z]{2,4}\b$/, :message => 'is not a valid email address'}
end
