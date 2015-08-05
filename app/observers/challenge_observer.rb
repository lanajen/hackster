class ChallengeObserver < ActiveRecord::Observer
  def after_update record
    if record.activate_banners_changed? and record.open_for_submissions? and platform = record.platform
      platform.active_challenge = record.display_banners?
      platform.save if platform.active_challenge_changed?
    end
  end

  def after_launch record
    if record.display_banners?
      platform = record.platform
      platform.active_challenge = true
      platform.save
    end
  end

  def after_take_offline record
    disable_challenge_on_platform record
  end

  def after_end record
    NotificationCenter.notify_all :completed, :challenge, record.id
    disable_challenge_on_platform record
  end

  def after_judging record
    record.entries.each do |entry|
      entry.has_prize? ? entry.give_award! : entry.give_no_award!
    end
  end

  private
    def disable_challenge_on_platform record
      if platform = record.platform
        platform.active_challenge = false
        platform.save
      end
    end
end