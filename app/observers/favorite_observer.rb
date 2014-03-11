class FavoriteObserver < ActiveRecord::Observer
  def after_create record
    update_counters record
    BaseMailer.enqueue_email 'new_respect_notification',
        { context_type: 'respect', context_id: record.id }
    record.user.broadcast :new, record.id, 'Favorite', record.project_id
  end

  def after_destroy record
    update_counters record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Favorite').destroy_all
  end

  private
    def update_counters record
      record.project.update_counters only: [:respects]
      record.user.update_counters only: [:respects]
    end
end