class ChallengeIdeaObserver < ActiveRecord::Observer
  def after_create record
    NotificationCenter.notify_via_email :new, :challenge_idea, record.id
    NotificationCenter.notify_via_email :new, :challenge_idea_admin, record.id
    expire_cache record
  end

  def after_update record
    custom = record.hstore_columns[:properties].select{|v| v =~ /cfield/ }
    if (record.changed & (%w(name description image) + custom)).any?
      expire_cache record
    end
  end

  def after_approve record
    NotificationCenter.notify_all :approved, :challenge_idea, record.id
  end

  def after_reject record
    NotificationCenter.notify_via_email :rejected, :challenge_idea, record.id
  end

  def after_destroy record
    expire_cache record
  end

  private
    def expire_cache record
      record.challenge.update_counters only: [:ideas]
      Cashier.expire "challenge-#{record.challenge_id}-ideas"
      FastlyWorker.perform_async 'purge', record.challenge.record_key
    end
end