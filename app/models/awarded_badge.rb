class AwardedBadge < ActiveRecord::Base
  belongs_to :awardee, polymorphic: true

  def badge
    @badge ||= Rewardino::Badge.find(badge_code)
  end
end