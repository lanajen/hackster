class FaqEntryObserver < ActiveRecord::Observer
  def after_create record
    expire_cache record if record.publyc?
  end

  def after_update record
    expire_cache record if record.publyc? or (record.private_changed? and record.pryvate?)
  end

  alias_method :after_destroy, :after_create

  private
    def expire_cache record
      Cashier.expire "challenge-#{record.threadable_id}-faq"
      record.threadable.purge
    end
end