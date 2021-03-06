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
  belongs_to :user, inverse_of: :reputation

  attr_accessible :points, :user_id, :redeemable_points, :redeemed_points
  validates :points, :user_id, presence: true
  # before_save :compute_redeemable, if: proc{ |r| r.points_changed? }

  def compute
    # self.points = (user.popularity_points_count * 0.1) + user.live_visible_projects_count * 10 + user.impressions_count * 0.01 + (user.name.present?.to_i + user.avatar.present?.to_i + user.mini_resume.present?.to_i + (user.city.present? or user.country.present?).to_i) * 2 + user.websites_count + user.interest_tags_count + user.skill_tags_count + user.comments_count * 3
    self.points = user.live_visible_projects_count * 1.5 + user.followers_count * 2 + user.projects.live.own.map{|p| p.team_members_count > 0 ? (p.real_respects_count * 3 + Math.log(p.impressions_count)) / p.team_members_count : 0 }.sum

    # self.points = user.live_visible_projects_count * 5 + user.respects_count + (user.project_views_count / 100).to_i + user.comments_count + 1 + user.accepted_invitations_count * 5 + (user.invited_by.present? ? 5 : 0) + (user.feed_likes_count / 5).to_i
    # self.points = user.reputation_events.sum(:points)
  end

  def compute_redeemable
    self.redeemed_points = user.orders.valid.sum(:total_cost)
    self.redeemable_points = user.reputation_count.to_i - redeemed_points
  end

  def compute_redeemable!
    compute_redeemable
    save
  end
end

# reputation = number of respects, number of followers, number of views (profile+project)

# find out how many people have enough reputation to buy something and have never bought anything
# User.not_hackster.user_name_set.where("NOT users.id IN (SELECT DISTINCT orders.user_id FROM orders WHERE orders.workflow_state != 'new')").joins(:reputation).where("reputations.redeemable_points > 129").count