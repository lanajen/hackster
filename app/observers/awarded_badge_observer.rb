class AwardedBadgeObserver < ActiveRecord::Observer
  def after_save record
    update_counters record

    NotificationCenter.notify_all :new, :badge, record.id if record.send_notification
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      user = record.awardee
      user.with_lock do
        user.update_counters only: [:badges_green, :badges_bronze, :badges_silver,
          :badges_gold]
      end
      Cashier.expire "user-#{record.awardee_id}-sidebar"
    end
end