class ChallengeIdeaObserver < ActiveRecord::Observer
  def after_create record
    NotificationCenter.notify_via_email :new, :challenge_idea, record.id
    # NotificationCenter.notify_via_email :new, :challenge_idea_admin, record.id unless record.challenge.auto_approve
  end

  # def after_update record
  #   if record.workflow_state_changed?
  #     if record.workflow_state == 'qualified'
  #       after_approve record
  #     elsif record.workflow_state == 'unqualified'
  #       after_disqualify record
  #     end
  #   end
  # end

  def after_approve record
    expire_cache record
    NotificationCenter.notify_all :approved, :challenge_idea, record.id
  end

  def after_reject record
    expire_cache record
    NotificationCenter.notify_all :rejected, :challenge_idea, record.id
  end

  # def after_give_award record
  #   NotificationCenter.notify_all :awarded, :challenge_entry, record.id

  #   Cashier.expire "project-#{record.project_id}-teaser"
  # end

  # def after_destroy record
  #   expire_cache record if record.project_id
  # end

  # alias_method :after_create, :after_destroy
  # alias_method :after_disqualify, :after_destroy

  # def after_award_not_given record
  #   NotificationCenter.notify_all :awarded, :challenge_entry, record.id
  # end

  private
    def expire_cache record
      record.challenge.update_counters only: [:ideas]
      Cashier.expire "challenge-#{record.challenge_id}-ideas"
      record.challenge.purge
    end
end