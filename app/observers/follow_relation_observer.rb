class FollowRelationObserver < ActiveRecord::Observer
  def after_commit_on_create record
    msg_type = "new_follower_notification_#{record.followable_type.underscore}"
    BaseMailer.enqueue_email msg_type,
        { context_type: 'follower', context_id: record.id } unless record.skip_notification? or (record.followable_type == 'Group' and record.followable.email.blank?)
  end

  def after_create record
    update_counters record
    case record.followable_type
    when 'Project'
      record.user.broadcast :new, record.id, 'FollowRelation', record.followable_id
    when 'Group'
      record.user.broadcast :new, record.id, 'FollowRelation', record.followable_id
      record.user.update_counters only: [:platforms]
      Cashier.expire "user-#{record.user_id}-sidebar"
    # when 'User'
    else
      Broadcast.create event: :new, user_id: record.user_id, context_model_id: record.id, context_model_type: 'FollowRelation', broadcastable_id: record.followable_id, broadcastable_type: 'User'
    end
  end

  def after_destroy record
    update_counters record
    Broadcast.where(context_model_id: record.id, context_model_type: 'FollowRelation').destroy_all
    case record.followable_type
    when 'Group'
      Cashier.expire "user-#{record.user_id}-sidebar"
    end
  end

  private
    def update_counters record
      record.followable.update_counters only: [:followers]
    end
end