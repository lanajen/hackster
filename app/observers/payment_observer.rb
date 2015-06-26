class PaymentObserver < ActiveRecord::Observer
  def after_send_email record
    NotificationCenter.notify_via_email :new, :payment, record.id
  end
end