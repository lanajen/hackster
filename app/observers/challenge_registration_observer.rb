class ChallengeRegistrationObserver < ActiveRecord::Observer
  def after_create record
    expire_cache record
    NotificationCenter.notify_via_email :new, :challenge_registration, record.id
    MailchimpWorker.perform_async 'add_new_participants_to_challenge', record.id if record.challenge.mailchimp_setup?
  end

  def after_destroy record
    expire_cache record
  end

  private
    def expire_cache record
      record.challenge.update_counters only: [:registrations]
      record.challenge.purge
    end
end