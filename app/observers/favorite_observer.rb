class FavoriteObserver < ActiveRecord::Observer
  def after_create record
    update_counters record
    BaseMailer.enqueue_email 'new_respect_notification',
        { context_type: 'respect', context_id: record.id }
  end

  def after_destroy record
    update_counters record
  end

  private
    def update_counters record
      record.project.update_counters only: [:respects]
      record.user.update_counters only: [:respects]
    end
end