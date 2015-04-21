class ReceiptObserver < ActiveRecord::Observer
  def after_create record
    case record.receivable_type
    when 'Comment'
      NotificationCenter.notify_all :new, :receipt, record.id unless record.is_read?
    when 'Notification'
      record.user.mark_has_unread_notifications!
    end
  end
end