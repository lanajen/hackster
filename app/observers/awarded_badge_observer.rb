class AwardedBadgeObserver < ActiveRecord::Observer
  def after_create record
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.awardee.update_counters only: [:badges]
      Cashier.expire "user-#{record.awardee_id}-sidebar"
    end
end