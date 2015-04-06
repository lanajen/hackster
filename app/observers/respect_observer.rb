class RespectObserver < ActiveRecord::Observer
  def after_commit_on_create record
    case record.respectable
    when Project
      BaseMailer.enqueue_email 'new_respect_notification',
          { context_type: 'respect', context_id: record.id }
      record.user.broadcast :new, record.id, 'Respect', record.respectable_id
    end
  end

  def after_create record
    update_counters record
  end

  def after_destroy record
    update_counters record
    Broadcast.where(context_model_id: record.id, context_model_type: 'Respect').destroy_all
  end

  private
    def update_counters record
      case record.respectable
      when Project
        record.respectable.update_counters only: [:respects], solo_counters: true
        Cashier.expire "project-#{record.respectable_id}-respects"
        record.user.update_counters only: [:respects]
      end
    end
end