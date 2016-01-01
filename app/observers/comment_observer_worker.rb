class CommentObserverWorker < BaseWorker
  sidekiq_options unique: :all, queue: :critical

  def after_commit_on_create record
    return if record.disable_notification?

    if record.commentable_type.in? %w(Issue BaseArticle Thought ReviewThread)
      NotificationCenter.notify_all :new, :comment, record.id
    end
    NotificationCenter.notify_all :mention, :comment_mention, record.id if record.has_mentions?
  end

  def after_create record
    case record.commentable_type
    when 'BaseArticle'
      update_counters record
      expire_cache record
    when 'ReviewThread'
      thread = record.commentable
      unless thread.closed?
        if record.user_id.in? thread.project.users.pluck('users.id')
          thread.update_column :workflow_state, :feedback_responded_to
        else
          thread.update_column :workflow_state, :feedback_given
        end
      end
    end
  end

  alias_method :after_update, :after_create
  alias_method :after_destroy, :after_create

  def perform method, record_id, *args
    with_logging method do
      record = Comment.find record_id
      send(method, record, *args)
    end
  rescue ActiveRecord::RecordNotFound, Timeout::Error => e
    message = "Error while working on '#{method}' in '#{self.class.name}' with args #{args}: \"#{e.message}\""
    Rails.logger.error message
    log_line = LogLine.create(message: message, log_type: 'error', source: 'worker')
  end

  private
    def expire_cache record
      cache_key = Comment.cache_key(record.commentable_type, record.commentable_id)
      FastlyWorker.perform_async 'purge', cache_key
    end

    def update_counters record
      if record.commentable_type == 'BaseArticle'
        record.commentable.update_counters only: [:comments]
        record.user.update_counters only: [:comments] if record.user
      end
    end
end