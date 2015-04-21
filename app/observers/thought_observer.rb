class ThoughtObserver < ActiveRecord::Observer
  def after_create record
    NotificationCenter.notify_all :mention, :thought_mention, record.id if record.has_mentions?
  end
end