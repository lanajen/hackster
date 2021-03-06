class AwardedBadge < ActiveRecord::Base
  include Notifiable

  belongs_to :awardee, polymorphic: true
  has_many :notifications, as: :notifiable, dependent: :delete_all

  attr_accessible :awardee_type, :awardee_id, :badge_code, :level, :send_notification
  attr_writer :send_notification

  validates :awardee_id, :awardee_type, :badge_code, :level, presence: true
  validates :badge_code, uniqueness: { scope: [:awardee_id, :awardee_type]}

  def badge
    @badge ||= Rewardino::Badge.find(badge_code)
  end

  def send_notification
    @send_notification.in? ['1', 1, true, 't']
  end
end