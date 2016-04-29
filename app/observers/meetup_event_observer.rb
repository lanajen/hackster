class MeetupEventObserver < ActiveRecord::Observer
  def after_create record
    record.meetup.update_counters only: [:events]
  end

  alias_method :after_destroy, :after_create
end