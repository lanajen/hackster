class FollowRelationObserver < ActiveRecord::Observer
  def after_commit_on_create record
    unless record.skip_notification? or (record.followable_type == 'Group' and record.followable.email.blank?) or record.followable_type.in? %(Project Part)
      NotificationCenter.notify_all :new, :follow_relation, record.id
    end
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
      case record.followable.class.name
      when 'HardwarePart', 'SoftwarePart', 'ToolPart', 'Part'
        record.followable.update_counters only: [:owners]
        record.user.update_counters only: [:owned_parts]
      when 'Project'
        record.followable.update_counters only: [:replications]
        record.user.update_counters only: [:replicated_projects]
        Cashier.expire "project-#{record.followable_id}-replications", "project-#{record.followable_id}"
        record.followable.purge
      when 'User'
        record.followable.update_counters only: [:followers]
      when 'Platform', 'List'
        record.followable.update_counters only: [:members]
        record.user.update_counters only: [:platforms], assign_only: record.user.persisted?
      end
    end
end