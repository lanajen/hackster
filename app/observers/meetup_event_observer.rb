class MeetupEventObserver < ActiveRecord::Observer
  def after_create record
    record.meetup.update_counters only: [:events]
  end

  alias_method :after_destroy, :after_create

  def after_update record
    if record.private_changed? and record.publyc?
      NotificationCenter.notify_all :new, :meetup_event, record.id
    end
  end
end