class PartObserver < ActiveRecord::Observer
  def after_commit record
    PartObserverWorker.perform_async 'after_commit', record.id
  end

  def after_destroy record
    PartObserverWorker.perform_async 'after_destroy', record.id
  end

  def after_update record
    PartObserverWorker.perform_async 'after_update', record.id, record.changed
  end
end