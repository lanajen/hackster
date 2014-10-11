class ChallengeEntryObserver < ActiveRecord::Observer
  def after_approve record
    BaseMailer.enqueue_email 'new_entry_accepted_notification',
      { context_type: 'challenge_entry', context_id: record.id }
  end

  def after_award_given record
    BaseMailer.enqueue_email 'entry_awarded_notification',
      { context_type: 'challenge_entry', context_id: record.id }
  end

  # def after_award_not_given record
  #   BaseMailer.enqueue_email 'entry_awarded_notification',
  #     { context_type: 'challenge_entry', context_id: record.id }
  # end
end