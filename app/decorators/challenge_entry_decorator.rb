class ChallengeEntryDecorator < ApplicationDecorator
  def status
    case model.workflow_state.to_sym
    when :new
      'Awaiting moderation'
    when :qualified, :approved
      'Approved'
    when :unqualified, :rejected
      'Rejected'
    when :awarded, :won
      'Awarded a prize!'
    when :unawarded, :lost
      'Did not win. Next time!'
    when :fulfilled
      'Prize sent'
    end
  end
end