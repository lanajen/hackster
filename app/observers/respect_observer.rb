class RespectObserver < ActiveRecord::Observer
  def after_create record
    update_counters record
    case record.respecting
    when User
      BaseMailer.enqueue_email 'new_respect_notification',
          { context_type: 'respect', context_id: record.id }
      record.respecting.broadcast :new, record.id, 'Respect', record.project_id
    end
  end

  def after_destroy record
    update_counters record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Respect').destroy_all
  end

  private
    def update_counters record
      record.project.update_counters only: [:respects], solo_counters: true
      case record.respecting
      when User
        Cashier.expire "project-#{record.project_id}-respects"
        record.respecting.update_counters only: [:respects]
      end
    end
end