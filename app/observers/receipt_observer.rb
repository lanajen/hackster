class ReceiptObserver < ActiveRecord::Observer
  def after_create record
    BaseMailer.enqueue_email 'new_message_notification',
      { context_type: 'message', context_id: record.id } unless
        record.is_read? or !'new_message'.in?(record.user.subscriptions)
  end
end