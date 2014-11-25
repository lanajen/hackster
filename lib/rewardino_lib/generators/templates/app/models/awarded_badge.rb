class AwardedBadge < ActiveRecord::Base
  belongs_to :awardee, polymorphic: true

  def badge
    Rewardino.get_badge(badge_code.to_sym)
  end
end
