class CommentObserver < ActiveRecord::Observer
  # include BroadcastObserver

  def after_commit_on_create record
    return if record.disable_notification?

    if record.commentable_type.in? %w(Issue Project Thought)
      NotificationCenter.notify_all :new, :comment, record.id
    end
    NotificationCenter.notify_all :mention, :comment_mention, record.id if record.has_mentions?
  end

  def after_create record
    if record.commentable_type == 'Project'
      project_id = record.commentable_id
      record.user.broadcast :new, record.id, 'Comment', project_id if record.user.class == User
      update_counters record
      expire_cache record
    end
  end

  def after_update record
    # update_counters record
  end

  def after_destroy record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Comment').destroy_all
    update_counters record
    expire_cache record if record.commentable_type == 'Project'
  end

  private
    def expire_cache record
      project = record.commentable
      Cashier.expire "project-#{project.id}-comments", "project-#{project.id}-left-column", "project-#{project.id}"
      project.purge
    end

    def update_counters record
      if record.commentable_type == 'Project'
        record.commentable.update_counters only: [:comments]
        record.user.update_counters only: [:comments] if record.user
      end
    end
end