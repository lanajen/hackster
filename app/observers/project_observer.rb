class ProjectObserver < ActiveRecord::Observer
  def after_create record
    update_counters record, :projects
  end

  def after_destroy record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
    update_counters record, [:projects, :live_projects]
  end

  def after_update record
    if record.private_changed?
      update_counters record, :live_projects
      if record.private?
        Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
      end
    end
  end

  def after_save record
    record.product_tags_count = record.product_tags_string.split(',').count
  end

  def before_create record
    record.reset_counters assign_only: true
  end

  private
    def update_counters record, type
      record.team_members.each{ |t| t.user.update_counters only: [type] }
    end
end