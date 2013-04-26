class ProjectObserver < ActiveRecord::Observer
  def after_create record
    %w(concept prototype pilot production).each do |name|
      record.stages.create(name: name)
    end
  end

  def after_destroy record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Project').destroy_all
  end
end