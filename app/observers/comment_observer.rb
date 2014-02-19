class CommentObserver < ActiveRecord::Observer
  # include BroadcastObserver

  def after_create record
    record.user.broadcast :new, record.id, 'Comment' if record.user.class == User
    type = (record.commentable.class.model_name == Issue ? 'new_comment_issue_notification' : 'new_comment_project_notification')
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
      return unless record.user
      if record.commentable.class == Project
        record.commentable.update_counters only: [:comments]
        record.user.update_counters only: [:comments]
      end
    end
end