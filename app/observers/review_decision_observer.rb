class ReviewDecisionObserver < ActiveRecord::Observer

  def after_create record
    record.review_thread.update_column :workflow_state, :feedback_given if record.decision == :needs_work

    NotificationCenter.notify_all :new, :review_decision, record.id
  end

  def after_update record
    case decision
    when 'approve'
      record.project.update_attribute :workflow_state, :approved
      record.review_thread.update_column :workflow_state, :closed
    when 'reject'
      record.project.update_attribute :workflow_state, :rejected
      record.review_thread.update_column :workflow_state, :closed
    end if record.approved_changed? and record.approved
  end
end