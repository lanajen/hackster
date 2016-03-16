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
      model.challenge.judged? ? 'Awarded a prize!' : 'Approved'
    when :unawarded
      model.challenge.judged? ? 'Did not win. Next time!' : 'Approved'
    when :fulfilled
      'Prize sent'
    end
  end
end