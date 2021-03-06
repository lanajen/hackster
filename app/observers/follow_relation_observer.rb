class FollowRelationObserver < ActiveRecord::Observer
  def after_commit_on_create record
    unless record.skip_notification? or (record.followable_type == 'Group' and record.followable.email.blank?) or record.followable_type.in? %(BaseArticle Part)
      NotificationCenter.notify_all :new, :follow_relation, record.id
    end
  end

  def after_create record
    update_counters record
    case record.followable_type
    when 'Group'
      record.user.update_counters only: [:platforms]
      Cashier.expire "user-#{record.user_id}-sidebar"
    end
  end

  def after_destroy record
    update_counters record
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
      when 'BaseArticle'
        record.followable.update_counters only: [:replications]
        record.user.update_counters only: [:replicated_projects]
        Cashier.expire "project-#{record.followable_id}-replications", "project-#{record.followable_id}"
        FastlyWorker.perform_async 'purge', record.followable.record_key
      when 'User'
        record.followable.update_counters only: [:followers]
      when 'Platform', 'List'
        record.followable.update_counters only: [:members]
        record.user.update_counters only: [:platforms], assign_only: record.user.persisted?
      end
    end
end