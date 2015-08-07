class ChallengeEntryObserver < ActiveRecord::Observer
  def after_approve record
    expire_cache record
    NotificationCenter.notify_all :approved, :challenge_entry, record.id
  end

  def after_give_award record
    NotificationCenter.notify_all :awarded, :challenge_entry, record.id

    Cashier.expire "project-#{record.project_id}-teaser"
  end

  def after_destroy record
    expire_cache record if record.project_id
  end

  alias_method :after_create, :after_destroy
  alias_method :after_disqualify, :after_destroy

  # def after_award_not_given record
  #   NotificationCenter.notify_all :awarded, :challenge_entry, record.id
  # end
  private
    def expire_cache record
      record.challenge.update_counters only: [:projects]
      Cashier.expire "project-#{record.project_id}-metadata", "challenge-#{record.challenge_id}-projects"
      record.challenge.purge
    end
end