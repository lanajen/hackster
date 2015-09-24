class ChallengeWorker < BaseWorker
  def do_after_judged id
    challenge = Challenge.find id

    challenge.entries.where(workflow_state: %w(new qualified)).each do |entry|
      entry.has_prize? ? entry.give_award! : entry.give_no_award!
    end
    expire_cache challenge
  end

  private
    def expire_cache challenge
      Cashier.expire "challenge-#{challenge.id}-projects", "challenge-#{challenge.id}-status"
      challenge.purge
    end
end