class NotificationObserver < ActiveRecord::Observer
  def after_create record
    record.recipients.each do |user|
      record.receipts.create user_id: user.id
    end
  end
end