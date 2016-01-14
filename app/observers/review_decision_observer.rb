class ReviewDecisionObserver < ActiveRecord::Observer

  def after_create record
    case record.decision.to_sym
    when :needs_work
      record.review_thread.update_column :workflow_state, :feedback_given
    when :reject, :approve
      record.review_thread.update_column :workflow_state, :decision_made
    end

    if record.user.can? :approve, record
      record.update_column :approved, true
      # approve/reject all other decisions
      record.review_thread.decisions.where.not(id: record.id).each do |decision|
        decision.update_column :approved, decision.decision.in?([record.decision, 'needs_work'])
      end
      finalize_decision record
    end

    NotificationCenter.notify_all :new, :review_decision, record.id
  end

  def after_update record
    finalize_decision record if record.approved_changed? and record.approved
  end

  private
    def finalize_decision record
      project = record.project
      thread = record.review_thread

      case record.decision
      when 'approve'
        project.approve_later! reviewer_id: record.user_id if project.can_approve?
        thread.update_column :workflow_state, :closed unless thread.closed?
      when 'reject'
        project.reject! reviewer_id: record.user_id if project.can_reject?
        thread.update_column :workflow_state, :closed unless thread.closed?
      end
    end
end