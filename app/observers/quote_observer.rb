class QuoteObserver < ActiveRecord::Observer
  def after_create record
    BaseMailer.enqueue_email "new_quote_notification",
      { context_type: :quote, context_id: record.id }
  end
end