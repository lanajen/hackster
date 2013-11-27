class Authorization < ActiveRecord::Base
  belongs_to :user
  validates :provider, :uid, presence: true
  validates :provider, length: { maximum: 50 }
  validates :uid, length: { maximum: 100 }
  attr_accessible :uid, :name, :link, :provider, :token, :secret
end
