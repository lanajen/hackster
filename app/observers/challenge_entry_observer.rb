class ChallengeEntryObserver < ActiveRecord::Observer

  def after_save record
    # for some obscure reason after_create isn't working anymore, so putting the code here
    if record.created_at > 5.seconds.ago
      # if the project is less than a minute old, we consider it new
      event = record.project.created_at > 1.minute.ago ? :new_w_new_project : :new_w_existing_project
      NotificationCenter.notify_via_email event, :challenge_entry, record.id
    end
  end

  def after_update record
    if record.workflow_state_changed?
      case record.workflow_state
      when 'qualified'
        after_approve record
      when 'submitted'
        after_submit record
      when 'unqualified'
        after_disqualify record
      end
    end
  end

  def after_submit record
    NotificationCenter.notify_via_email :submitted, :challenge_entry, record.id
    NotificationCenter.notify_via_email :new, :challenge_entry_admin, record.id unless record.challenge.auto_approve
  end

  def after_approve record
    project = record.project
    expire_cache record
    NotificationCenter.notify_all :approved, :challenge_entry, record.id
  end

  def after_disqualify record
    expire_cache record
    NotificationCenter.notify_via_email :rejected, :challenge_entry, record.id
  end

  def after_give_award record
    NotificationCenter.notify_all :awarded, :challenge_entry, record.id

    Cashier.expire "project-#{record.project_id}-teaser", "project-#{record.project_id}"
  end

  def after_destroy record
    expire_cache record if record.project_id
  end

  alias_method :after_create, :after_destroy
  alias_method :after_disqualify, :after_destroy

  private
    def expire_cache record
      record.challenge.update_counters only: [:projects]
      Cashier.expire "project-#{record.project_id}-metadata", "challenge-#{record.challenge_id}-projects"
      FastlyWorker.perform_async 'purge', record.challenge.record_key
    end
end