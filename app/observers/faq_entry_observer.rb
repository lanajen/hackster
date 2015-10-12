class FaqEntryObserver < ActiveRecord::Observer
  def after_create record
    expire_cache record if record.public?
  end

  def after_update record
    expire_cache record if record.public? or (record.private_changed? and record.private?)
  end

  alias_method :after_destroy, :after_create

  private
    def expire_cache record
      Cashier.expire "challenge-#{record.threadable_id}-faq"
      record.threadable.purge
    end
end