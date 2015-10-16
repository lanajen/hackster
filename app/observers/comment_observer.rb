class CommentObserver < ActiveRecord::Observer

  def after_commit_on_create record
    return if record.disable_notification?

    if record.commentable_type.in? %w(Issue BaseArticle Thought)
      NotificationCenter.notify_all :new, :comment, record.id
    end
    NotificationCenter.notify_all :mention, :comment_mention, record.id if record.has_mentions?
  end

  def after_create record
    if record.commentable_type == 'BaseArticle'
      project_id = record.commentable_id
      update_counters record
      expire_cache record
    end
  end

  def after_update record
    # update_counters record
  end

  def after_destroy record
    update_counters record
    expire_cache record if record.commentable_type == 'BaseArticle'
  end

  private
    def expire_cache record
      project = record.commentable
      Cashier.expire "project-#{project.id}-comments", "project-#{project.id}-left-column", "project-#{project.id}"
      project.purge
    end

    def update_counters record
      if record.commentable_type == 'BaseArticle'
        record.commentable.update_counters only: [:comments]
        record.user.update_counters only: [:comments] if record.user
      end
    end
end