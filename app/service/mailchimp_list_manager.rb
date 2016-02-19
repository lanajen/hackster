class MailchimpListManager
  attr_accessor :timeout_count

  def add users
    ENV['MAILCHIMP_ACTIVE'] ? add_subscribers_in_batches(users) : []
  end

  def initialize api_key, list_id
    Gibbon::API.api_key = api_key
    @list_id = list_id
  end

  def remove users
    ENV['MAILCHIMP_ACTIVE'] ? remove_subscribers_in_batches(users) : []
  end

  private
    def add_subscribers users
      puts "Adding #{users.count} subscribers to list #{@list_id}."
      batch = batch_from_user_list users
      response = gb.lists.batch_subscribe({ id: @list_id, batch: batch, double_optin: false, update_existing: true })
      failed_emails = response['errors'].map { |error| error['email']['email'] }
      successful_emails = get_email_from_users(users) - failed_emails
      puts "Results for adding: #{successful_emails.size} successes, #{failed_emails.size} failures."
      return { success: successful_emails, fail: failed_emails }
    rescue Net::ReadTimeout
      timeout_count = timeout_count ? timeout_count + 1 : 1
      if timeout_count < 3
        puts "Timeout! Trying again... (#{timeout_count})"
        add_subscribers users
      else
        puts "3 timeouts, giving up."
        { success: [], fail: [] }
      end
    end

    def add_subscribers_in_batches users
      users.each_slice(250).map do |slice|
        add_subscribers slice
      end.inject({}){|mem, h| mem.merge(h); h }
    end

    def batch_from_user_list users
      users.map { |u| {
        email: { email: u.email },
        email_type: 'html',
        merge_vars: { full_name: u.full_name },
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
      return { success: successful_emails, fail: failed_emails }
    end

    def remove_subscribers_in_batches users
      users.each_slice(250).map do |slice|
        remove_subscribers slice
      end.inject({}){|mem, h| mem.merge(h); h }
    end
end