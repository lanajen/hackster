class ChallengeObserver < ActiveRecord::Observer
  def after_end record
    BaseMailer.enqueue_email 'challenge_ended_notification',
      { context_type: 'challenge', context_id: record.id }
  end

  def after_judging record
    record.entries.each do |entry|
      entry.awarded? ? entry.give_award! : entry.give_no_award!
    end
  end
end