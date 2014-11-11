class ChallengeObserver < ActiveRecord::Observer
  def after_launch record
    if tech = record.tech
      tech.active_challenge = true
      tech.save
    end
  end

  def after_end record
    BaseMailer.enqueue_email 'challenge_ended_notification',
      { context_type: 'challenge', context_id: record.id }
    if tech = record.tech
      tech.active_challenge = false
      tech.save
    end
  end

  def after_judging record
    record.entries.each do |entry|
      entry.prize_id.present? ? entry.give_award! : entry.give_no_award!
    end
  end
end