class ChallengeIdeaObserver < ActiveRecord::Observer
  def after_create record
    NotificationCenter.notify_via_email :new, :challenge_idea, record.id
    NotificationCenter.notify_via_email :new, :challenge_idea_admin, record.id unless record.challenge.auto_approve
  end

  def after_approve record
    expire_cache record
    NotificationCenter.notify_all :approved, :challenge_idea, record.id
  end

  def after_reject record
    expire_cache record
    NotificationCenter.notify_via_email :rejected, :challenge_idea, record.id
  end

  def after_mark_needs_approval record
    expire_cache record
  end

  def after_destroy record
    expire_cache record
  end

  private
    def expire_cache record
      record.challenge.update_counters only: [:ideas]
      Cashier.expire "challenge-#{record.challenge_id}-ideas"
      record.challenge.purge
    end
end