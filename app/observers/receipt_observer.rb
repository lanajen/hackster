class ReceiptObserver < ActiveRecord::Observer
  def after_create record
    NotificationCenter.notify_all :new, :receipt, record.id unless record.is_read?
  end
end