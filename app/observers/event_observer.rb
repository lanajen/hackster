class EventObserver < ActiveRecord::Observer
  def after_save record
    if record.private_changed?
      record.hackathon.update_counters only: [:events]
    end
  end
end