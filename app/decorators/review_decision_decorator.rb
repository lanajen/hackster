class ReviewDecisionDecorator < ApplicationDecorator
  def decision
    model.decision.humanize
  end

  def rejection_reason
    ReviewDecision::REJECTION_REASONS[model.rejection_reason.try(:to_sym)]
  end
end