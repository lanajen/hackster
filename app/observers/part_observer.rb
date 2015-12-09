class PartObserver < ActiveRecord::Observer
  def after_commit record
    PartObserverWorker.perform_async 'after_commit', record.id
  end

  def after_destroy record
    PartObserverWorker.new.after_destroy record  # synchronous
  end

  def after_update record
    PartObserverWorker.perform_async 'after_update', record.id, record.changed
  end
end