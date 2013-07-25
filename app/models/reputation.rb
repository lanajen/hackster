#
# new project: 10
# complete profile:
#   - avatar, mini resume, location: 5 per
#   - websites: 2 per
#   - interests, skills: 5 per
# project commented on: 1 per comment
#

class Reputation < ActiveRecord::Base
  belongs_to :user

  attr_accessible :points, :user_id
  validates :points, numericality: { only_integer: true }
  validates :points, :user_id, presence: true
end
