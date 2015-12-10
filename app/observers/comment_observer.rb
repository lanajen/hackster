class CommentObserver < ActiveRecord::Observer

  def after_commit_on_create record
    CommentObserverWorker.perform_async 'after_commit_on_create', record.id
  end

  def after_create record
    CommentObserverWorker.perform_async 'after_create', record.id
  end

  def after_update record
    CommentObserverWorker.perform_async 'after_update', record.id
  end

  def after_destroy record
    CommentObserverWorker.new.after_destroy record  # synchronous
  end
end