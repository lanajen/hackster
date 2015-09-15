class ChallengeEntryDecorator < ApplicationDecorator
  def status
    case model.workflow_state.to_sym
    when :new
      'Awaiting moderation'
    when :qualified
      'Approved'
    when :unqualified
      'Rejected'
    when :awarded
      'Awarded a prize!'
    when :unawarded
      'Did not win. Next time!'
    when :fulfilled
      'Prize sent'
    end
  end
end