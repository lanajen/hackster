class ChallengeEntryObserver < ActiveRecord::Observer
  def after_approve record
    record.challenge.update_counters only: [:projects]
    Cashier.expire "project-#{record.project_id}-metadata"
    NotificationCenter.notify_all :approved, :challenge_entry, record.id
  end

  def after_award_given record
    NotificationCenter.notify_all :awarded, :challenge_entry, record.id

    Cashier.expire "project-#{record.project_id}-teaser"
  end

  def after_destroy record
    Cashier.expire "project-#{record.project_id}-metadata" if record.project_id
  end

  # def after_award_not_given record
  #   NotificationCenter.notify_all :awarded, :challenge_entry, record.id
  # end
end