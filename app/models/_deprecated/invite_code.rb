class InviteCode < ActiveRecord::Base
  has_many :users
  attr_accessible :code, :limit, :active
  validates :code, length: { maximum: 20 }, presence: true

  def self.authenticate code
    # returns invite if valid, nil/false otherwise
    (invite = find_by_code(code) and invite.can_be_redeemed? and invite)
  end

  def active?
    active
  end

  def available?
    limit.nil? or (limit > 0 and limit > users.size)
  end

  def can_be_redeemed?
    active? and available?
  end
end
