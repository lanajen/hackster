class ProjectObserver < ActiveRecord::Observer
  def after_create record
#    %w(concept prototype pilot production).each do |name|
#      record.stages.create(name: name)
#    end
#    record.stages.where(name: 'concept').update_all(workflow_state: :open)
    update_counters record, :projects
  end

  def after_destroy record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
    update_counters record, :projects
  end

  def after_update record
    if record.private_changed?
      update_counters record, :live_projects
    end
  end

  def after_save record
    # record.update_counters only: [:product_tags]
    record.product_tags_count = record.product_tags_string.split(',').count
  end

  private
    def update_counters record, type
      record.team_members.each{ |t| t.user.update_counters only: [type] }
    end
end