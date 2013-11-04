class ProjectObserver < ActiveRecord::Observer
  def after_create record
#    %w(concept prototype pilot production).each do |name|
#      record.stages.create(name: name)
#    end
#    record.stages.where(name: 'concept').update_all(workflow_state: :open)
    update_counters record
  end

  def after_destroy record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
    update_counters record
  end

  def after_save record
    # record.update_counters only: [:product_tags]
    record.product_tags_count = record.product_tags_string.split(',').count
  end

  private
    def update_counters record
      record.user.update_counters only: [:projects]
    end
end