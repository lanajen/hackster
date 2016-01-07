class FaqEntryObserver < ActiveRecord::Observer
  def after_create record
    expire_cache record if record.publyc?
  end

  def after_update record
    expire_cache record if record.publyc? or (record.private_changed? and record.pryvate?)
  end

  def before_save record
    token_tags = record.token_tags.try(:dup) || {}
    (record.changed & FaqEntry::TOKEN_PARSABLE_ATTRIBUTES).each do |attr|
      parser = TokenParser.new record.threadable, record.send(attr)
      token_tags[attr] = (parser.all_cleaned & record.threadable_type.constantize::TOKENABLE_ATTRIBUTES)
    end
    record.token_tags = token_tags
  end

  alias_method :after_destroy, :after_create

  private
    def expire_cache record
      Cashier.expire "challenge-#{record.threadable_id}-faq", "challenge-#{record.threadable_id}-faq-cache-tags"
      FastlyWorker.perform_async 'purge', record.threadable.record_key
    end
end