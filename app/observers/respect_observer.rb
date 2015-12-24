class RespectObserver < ActiveRecord::Observer
  def after_commit_on_create record
    NotificationCenter.notify_all :new, :respect, record.id if record.respectable_type.in? %w(BaseArticle Comment)
  end

  def after_create record
    update_counters record
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      case record.respectable
      when ChallengeEntry
        record.respectable.update_counters only: [:votes]
      when BaseArticle
        record.respectable.update_counters only: [:respects]
        Cashier.expire "project-#{record.respectable_id}-respects", "project-#{record.respectable_id}"
        FastlyWorker.perform_async 'purge', record.respectable.record_key
        record.user.update_counters only: [:respects]
      when Comment
        cache_key = Comment.cache_key 'BaseArticle', record.respectable.commentable_id
        FastlyWorker.perform_async 'purge', cache_key
      end
    end
end