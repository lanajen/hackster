class ChallengeEntryDecorator < ApplicationDecorator
  def status
    case model.workflow_state.to_sym
    when :new
      'Awaiting moderation'
    when :qualified, :approved
      'Approved'
    when :unqualified, :rejected
      'Rejected'
    when :awarded
      model.challenge.judged? ? 'Awarded a prize!' : 'Approved'
    when :unawarded
      model.challenge.judged? ? 'Did not win. Next time!' : 'Approved'
    when :won
      model.challenge.pre_contest_awarded? ? 'Won!' : 'Approved'
    when :lost
      model.challenge.pre_contest_awarded? ? 'Did not win. Next time!' : 'Approved'
    when :fulfilled
      'Prize sent'
    end
  end
end