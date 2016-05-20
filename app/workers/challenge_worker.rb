class ChallengeWorker < BaseWorker
  def do_after_end id
    challenge = Challenge.find id

    challenge.projects.merge(ChallengeEntry.submitted).each do |project|
      project.update_attribute :locked, true
    end
  end

  def do_after_judged id
    challenge = Challenge.find id

    challenge.projects.each do |project|
      project.update_attribute :locked, false
    end
    challenge.entries.where(workflow_state: %w(new submitted qualified)).each do |entry|
      entry.has_prize? ? entry.give_award! : entry.give_no_award!
    end
    expire_cache challenge

    NotificationCenter.notify_all :judged, :challenge, id
  end

  def populate_default_faq id
    DefaultFaqEntry.populate_challenge_defaults id
  end

  private
    def expire_cache challenge
      Cashier.expire "challenge-#{challenge.id}-projects", "challenge-#{challenge.id}-status"
      FastlyWorker.perform_async 'purge', challenge.record_key
    end
end