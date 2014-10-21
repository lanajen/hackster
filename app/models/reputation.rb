#
# new project: 10
# complete profile:
#   - name, avatar, mini resume, location: 5 per
#   - websites: 1 per
#   - interests, skills: 1 per
# project commented on: 3 per comment
# featured project: 10
# special award: 1-10
#

class Reputation < ActiveRecord::Base
  belongs_to :user

  attr_accessible :points, :user_id
  validates :points, :user_id, presence: true

  def compute
    self.points = (user.popularity_points_count * 0.1) + user.live_visible_projects_count * 10 + user.impressions_count * 0.01 + (user.name.present?.to_i + user.avatar.present?.to_i + user.mini_resume.present?.to_i + (user.city.present? or user.country.present?).to_i) * 2 + user.websites_count + user.interest_tags_count + user.skill_tags_count + user.comments_count * 3
  end
end
