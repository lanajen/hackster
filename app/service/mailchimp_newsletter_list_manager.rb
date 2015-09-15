class MailchimpNewsletterListManager < MailchimpListManager
  def add users
    result = super(users)
    return if result.empty?

    update_settings_for result[:fail], "subscriptions_masks = subscriptions_masks || hstore('email', (CAST(subscriptions_masks -> 'email' AS INTEGER) - #{2**User::SUBSCRIPTIONS[:email].keys.index('newsletter')})::varchar)"
    update_settings_for result[:success], { mailchimp_registered: true }
  end

  def remove users
    result = super(users)
    return if result.empty?
    update_settings_for result[:success], { mailchimp_registered: false }
  end

  def update!
    subscribers = find_subscribers_that_need_update subscribe: true
    add(subscribers)

    cancellers = find_subscribers_that_need_update subscribe: false
    remove(cancellers)
  end

  private
    def find_subscribers_that_need_update opts={}
      users = User.where(mailchimp_registered: !opts[:subscribe])
      users = if opts[:subscribe]
        users.with_subscription(:email, :newsletter)
      else
        users.without_subscription(:email, :newsletter)
      end
      users
    end

    def update_settings_for emails, settings
      User.where(email: emails).update_all(settings) if emails.any?
    end
end