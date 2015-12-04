class PartJoinObserver < ActiveRecord::Observer
  def after_commit_on_create record
    PartJoinObserverWorker.perform_async 'after_commit_on_create', record.id
  end

  def after_destroy record
    PartJoinObserverWorker.perform_async 'after_destroy', record.id
  end

  def after_update record
    PartJoinObserverWorker.perform_async 'after_update', record.id, record.changed
  end
end