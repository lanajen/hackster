class ReviewDecisionObserver < ActiveRecord::Observer

  def after_create record
    case record.decision
    when :needs_work
      record.review_thread.update_column :workflow_state, :feedback_given
    when :rejected, :approved
      record.review_thread.update_column :workflow_state, :decision_made
    end

    if record.user.can? :approve, record
      record.update_column :approved, true
      finalize_decision record
    end

    NotificationCenter.notify_all :new, :review_decision, record.id
  end

  def after_update record
    finalize_decision record if record.approved_changed? and record.approved
  end

  private
    def finalize_decision record
      case record.decision
      when 'approve'
        record.project.approve_later!
        record.review_thread.update_column :workflow_state, :closed
      when 'reject'
        record.project.reject!
        record.review_thread.update_column :workflow_state, :closed
      end
    end
end