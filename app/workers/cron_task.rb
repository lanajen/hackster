class CronTask < BaseWorker
  @queue = :cron

  def launch_cron
    # do nothing, trick to execute tracker_queue tasks
  end

#  def update_mailchimp_list platform_id=nil
#    platforms = platform_id ? [Platform.find(platform_id)] : Platform.all
#
#    platforms.each do |platform|
#      api_key = platform.mailchimp_api_key
#      list_id = platform.mailchimp_list_id
#      next if api_key.blank? or list_id.blank?
#      gb = Gibbon.new(api_key)
#
#      subscribers = subscription_changes_with true, platform
#      add_subscribers(gb, list_id, subscribers) unless subscribers.empty?
#
#      cancellers = subscription_changes_with false, platform
#      remove_subscribers(gb, list_id, cancellers) unless cancellers.empty?
#    end
#  end
#
#  private
#    def add_subscribers gb, list_id, users
#      puts "Adding #{users.count} subscribers to list #{list_id}."
#      batch = batch_from_user_list users
#      response = gb.list_batch_subscribe({ id: list_id, batch: batch, double_optin: false, update_existing: true })
#      failed_emails = response['errors'].map { |error| error['email'] }
#      successful_emails = get_email_from_users(users) - failed_emails
#      update_settings_for failed_emails, { receive_newsletter: false }
#      update_settings_for successful_emails, { mailchimp_registered: true }
#      puts "Results for adding: #{successful_emails.size} successes, #{failed_emails.size} failures."
#    end
#
#    def batch_from_user_list users
#      users.map { |u| {
#          'EMAIL' => u.email,
#          'EMAIL_TYPE' => 'html',
#          'FNAME' => u.first_name,
#          'LNAME' => u.last_name,
##          'PMANAGER' => u.is_project_manager?,
#        } }
#    end
#
#    def get_email_from_users users
#      users.map { |u| u.email }
#    end
#
#    def remove_subscribers gb, list_id, users
#      puts "Removing #{users.count} subscribers from list #{list_id}."
#      emails = get_email_from_users users
#      gb.list_batch_unsubscribe({ id: list_id, emails: emails, delete_member: true, send_goodbye: false, send_notify: false })
#      update_settings_for emails, { mailchimp_registered: false }
#    end
#
#    def subscription_changes_with change_type, platform
#      User.joins(:authentications).where('platform_users.receive_newsletter <> platform_users.mailchimp_registered AND platform_users.receive_newsletter = ?', change_type).where('platform_users.platform_id = ?', platform.id)
#    end
#
#    def update_settings_for emails, settings
#      Authentication.joins(:user).where("users.email IN (?)", emails).update_all(settings) if emails.any?
#    end
end