class ChallengeWorker < BaseWorker
  def announce_pre_contest_winners id
    challenge = Challenge.find id

    challenge.ideas.where(workflow_state: %w(new approved)).each do |idea|
      idea.mark_lost!
    end
    Cashier.expire "challenge-#{challenge.id}-ideas", "challenge-#{challenge.id}-brief"
    FastlyWorker.perform_async 'purge', challenge.record_key

    NotificationCenter.notify_all :pre_contest_awarded, :challenge, id, 'pre_contest_awarded'
    NotificationCenter.notify_all :pre_contest_winners, :challenge, id, 'awarded_challenge_idea'
  end

  def do_after_judged id
    challenge = Challenge.find id

    challenge.entries.where(workflow_state: %w(new qualified)).each do |entry|
      entry.has_prize? ? entry.give_award! : entry.give_no_award!
    end
    expire_cache challenge

    NotificationCenter.notify_all :judged, :challenge, id
  end

  private
    def expire_cache challenge
      Cashier.expire "challenge-#{challenge.id}-projects", "challenge-#{challenge.id}-status"
      FastlyWorker.perform_async 'purge', challenge.record_key
    end
end