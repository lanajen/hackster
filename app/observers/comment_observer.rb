class CommentObserver < ActiveRecord::Observer
  # include BroadcastObserver

  def after_create record
    project_id = record.commentable_type == 'Project' ? record.commentable_id : record.commentable.threadable_id
    record.user.broadcast :new, record.id, 'Comment', project_id if record.user.class == User
    type = case record.commentable.class.model_name
    when 'Issue'
      'new_comment_issue_notification'
    when 'Project'
      'new_comment_project_notification'
    else
      return
    end
    BaseMailer.enqueue_email type,
        { context_type: 'comment', context_id: record.id } unless record.disable_notification?
    update_counters record
  end

  def after_update record
    # update_counters record
  end

  def after_destroy record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Comment').destroy_all
    update_counters record
  end

  private
    def update_counters record
      if record.commentable.class == Project
        record.commentable.update_counters only: [:comments]
        record.user.update_counters only: [:comments] if record.user
      end
    end
end