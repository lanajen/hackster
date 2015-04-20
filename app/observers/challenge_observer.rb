class ChallengeObserver < ActiveRecord::Observer
  def after_launch record
    if platform = record.platform
      platform.active_challenge = true
      platform.save
    end
  end

  def after_end record
    NotificationCenter.notify_all :completed, :challenge, record.id
    if platform = record.platform
      platform.active_challenge = false
      platform.save
    end
  end

  def after_judging record
    record.entries.each do |entry|
      entry.prize_id.present? ? entry.give_award! : entry.give_no_award!
    end
  end
end