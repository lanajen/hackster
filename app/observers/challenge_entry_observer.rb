class ChallengeEntryObserver < ActiveRecord::Observer
  def after_approve record
    record.challenge.update_counters only: [:projects]
    BaseMailer.enqueue_email 'new_entry_accepted_notification',
      { context_type: 'challenge_entry', context_id: record.id }
  end

  def after_award_given record
    BaseMailer.enqueue_email 'entry_awarded_notification',
      { context_type: 'challenge_entry', context_id: record.id }

    Cashier.expire "project-#{record.project_id}-teaser"
  end

  # def after_award_not_given record
  #   BaseMailer.enqueue_email 'entry_awarded_notification',
  #     { context_type: 'challenge_entry', context_id: record.id }
  # end
end