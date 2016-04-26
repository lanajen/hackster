class MouserSubmissionObserver < ActiveRecord::Observer
  def after_create record
    NotificationCenter.perform_async 'notify_via_email', :new, :mouser_submission, record.id
  end
end