class MailchimpWorker < BaseWorker
  def add_new_participants_to_challenge id
    registration = ChallengeRegistration.find id
    challenge = registration.challenge
    users = [registration.user]

    MailchimpListManager.new(challenge.mailchimp_api_key, challenge.mailchimp_list_id).add(users)
    challenge.update_attribute :mailchimp_last_synced_at, Time.now
  end

  def sync_challenge id
    challenge = Challenge.find id
    challenge.sync_mailchimp!
  end
end