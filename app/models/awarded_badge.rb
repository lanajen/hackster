class AwardedBadge < ActiveRecord::Base
  belongs_to :awardee, polymorphic: true

  attr_accessible :awardee_type, :awardee_id, :badge_code

  validates :awardee_id, :awardee_type, :badge_code, presence: true
  validates :badge_code, uniqueness: { scope: [:awardee_id, :awardee_type]}

  def badge
    @badge ||= Rewardino::Badge.find(badge_code)
  end
end