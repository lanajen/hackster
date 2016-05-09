class MeetupEventObserver < ActiveRecord::Observer
  def after_destroy record
    record.meetup.update_counters only: [:events]
  end

  def after_update record
    if record.private_changed?
      record.meetup.update_counters only: [:events]
      if record.publyc?
        NotificationCenter.notify_all :new, :meetup_event, record.id
      end
    end
  end
end