class ChallengeEntryObserver < ActiveRecord::Observer
  def after_create record
    NotificationCenter.notify_via_email :new, :challenge_entry, record.id
    NotificationCenter.notify_via_email :new, :challenge_entry_admin, record.id unless record.challenge.auto_approve
  end

  def after_update record
    if record.workflow_state_changed?
      if record.workflow_state == 'qualified'
        after_approve record
      elsif record.workflow_state == 'unqualified'
        after_disqualify record
      end
    end
  end

  def after_approve record
    project = record.project
    if tag = record.challenge.platform.try(:platform_tags).try(:first).try(:name) and !tag.in? project.platform_tags_cached
      project.platform_tags << PlatformTag.new(name: tag)
    end
    expire_cache record
    NotificationCenter.notify_all :approved, :challenge_entry, record.id
  end

  def after_disqualify record
    expire_cache record
    NotificationCenter.notify_via_email :rejected, :challenge_entry, record.id
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

  private
    def expire_cache record
      record.challenge.update_counters only: [:projects]
      Cashier.expire "project-#{record.project_id}-metadata", "challenge-#{record.challenge_id}-projects"
      record.challenge.purge
    end
end