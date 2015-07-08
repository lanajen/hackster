class MailchimpListManager
  def initialize api_key, list_id
    Gibbon::API.api_key = api_key
    @list_id = list_id
  end

  def update_list
    subscribers = find_subscribers_that_need_update subscribe: true
    add_subscribers_in_batches(subscribers) unless subscribers.empty?

    cancellers = find_subscribers_that_need_update subscribe: false
    remove_subscribers_in_batches(cancellers) unless cancellers.empty?
  end

  private
    def add_subscribers users
      puts "Adding #{users.count} subscribers to list #{@list_id}."
      batch = batch_from_user_list users
      response = gb.lists.batch_subscribe({ id: @list_id, batch: batch, double_optin: false, update_existing: true })
      failed_emails = response['errors'].map { |error| error['email']['email'] }
      successful_emails = get_email_from_users(users) - failed_emails
      update_settings_for failed_emails, "subscriptions_masks = subscriptions_masks || hstore('email', (CAST(subscriptions_masks -> 'email' AS INTEGER) - #{2**User::SUBSCRIPTIONS[:email].keys.index('newsletter')})::varchar)"
      update_settings_for successful_emails, { mailchimp_registered: true }
      puts "Results for adding: #{successful_emails.size} successes, #{failed_emails.size} failures."
    end

    def add_subscribers_in_batches users
      users.each_slice(1000).each do |slice|
        add_subscribers slice
      end
    end

    def batch_from_user_list users
      users.map { |u| {
        email: { email: u.email },
        email_type: 'html',
      } }
    end

    def gb
      @gb ||= Gibbon::API
    end

    def get_email_from_users users
      users.map(&:email)
    end

    def remove_subscribers users
      puts "Removing #{users.count} subscribers from list #{@list_id}."
      emails = get_email_from_users(users).map{|e| { email: e }}
      response = gb.lists.batch_unsubscribe({ id: @list_id, batch: emails, delete_member: true, send_goodbye: false, send_notify: false })
      failed_emails = response['errors'].map { |error| error['email']['email'] }
      successful_emails = get_email_from_users(users) - failed_emails
      update_settings_for successful_emails, { mailchimp_registered: false }
    end

    def remove_subscribers_in_batches users
      users.each_slice(1000).each do |slice|
        remove_subscribers slice
      end
    end

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