class CommentObserver < ActiveRecord::Observer
  include BroadcastObserver

  def after_create record
    record.user.broadcast :new, record.id, observed_model if record.user.class == User
    BaseMailer.enqueue_email 'new_comment_notification',
        { context_type: 'comment', context_id: record.id }
    update_counters record
  end

  def after_update record
#    record.user.broadcast :update, record.id, observed_model
  end

  def after_destroy record
  #    Broadcast.where(context_model_id: record.id, context_model_type: observed_model).destroy_all
    update_counters record
  end

  private
    def update_counters record
      record.commentable.update_counters only: [:comments] if record.commentable.class == Project
      record.user.update_counters only: [:comments]
    end
end