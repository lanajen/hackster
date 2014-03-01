class FollowRelationObserver < ActiveRecord::Observer
  def after_create record
    update_counters record
    msg_type = "new_follower_notification_#{record.followable_type.underscore}"
    BaseMailer.enqueue_email msg_type,
        { context_type: 'follower', context_id: record.id }
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.followable.update_counters only: [:followers]
    end
end