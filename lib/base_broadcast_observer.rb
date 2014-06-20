class BaseBroadcastObserver < ActiveRecord::Observer
  def after_create record
    record.user.broadcast :new, record.id, observed_model, project_id(record) if record.user
  end

  def after_update record
    record.user.broadcast :update, record.id, observed_model, project_id(record) if record.user
  end

  def after_destroy record
    Broadcast.where(context_model_id: record.id, context_model_type: observed_model).destroy_all
    Broadcast.where(broadcastable_id: record.id, broadcastable_type: observed_model).destroy_all
  end

  private
    def project_id record
      nil
    end

    def observed_model
      self.class.observed_class.name
    end
end