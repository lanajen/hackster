class CronTask < BaseWorker
  # @queue = :low
  sidekiq_options queue: :low, retry: 0

  def compute_popularity
    Project.find_each do |project|
      project.update_counters
      project.compute_popularity
      project.save
    end
    User.invitation_accepted_or_not_invited.find_each do |user|
      user.update_counters
      user.build_reputation unless user.reputation
      reputation = user.reputation
      reputation.compute
      reputation.save
    end
    Tech.find_each do |tech|
      tech.update_counters
    end
  end

  def launch_cron
    update_mailchimp_list
  end

  def launch_daily_cron
    begin
      compute_popularity
      send_daily_notifications
      self.class.perform_in 24.hours, 'launch_daily_cron'
    rescue => e
      Rails.logger.error "Error in launch_daily_cron: #{e.inspect}"
      self.class.perform_in 24.hours, 'launch_daily_cron'
    ensure
      # self.class.perform_in 24.hours, 'launch_daily_cron'
    end
  end

  def send_daily_notifications
    teches = Tech.joins(:group_relations).where('group_relations.created_at > ?', 24.hours.ago).where(group_relations: { workflow_state: GroupRelation::VALID_STATES }).distinct(:id)
    teches.each do |tech|
      BaseMailer.enqueue_email 'new_projects_in_tech_notification', { context_type: 'tech', context_id: tech.id }
    end
  end

  def update_mailchimp_list
    gb = Gibbon::API
    list_id = MAILCHIMP_LIST_ID

    subscribers = subscription_changes_with true
    add_subscribers(gb, list_id, subscribers) unless subscribers.empty?

    cancellers = subscription_changes_with false
    remove_subscribers(gb, list_id, cancellers) unless cancellers.empty?
  end

  private
    def add_subscribers gb, list_id, users
      puts "Adding #{users.count} subscribers to list #{list_id}."
      batch = batch_from_user_list users
      response = gb.lists.batch_subscribe({ id: list_id, batch: batch, double_optin: false, update_existing: true })
      failed_emails = response['errors'].map { |error| error['email']['email'] }
      successful_emails = get_email_from_users(users) - failed_emails
      update_settings_for failed_emails, "subscriptions_mask = (subscriptions_mask - #{2**User::SUBSCRIPTIONS.keys.index('newsletter')})"
      update_settings_for successful_emails, { mailchimp_registered: true }
      puts "Results for adding: #{successful_emails.size} successes, #{failed_emails.size} failures."
    end

    def batch_from_user_list users
      users.map { |u| {
        email: { email: u.email },
        email_type: 'html',
      } }
    end

    def get_email_from_users users
      users.map(&:email)
    end

    def remove_subscribers gb, list_id, users
      puts "Removing #{users.count} subscribers from list #{list_id}."
      emails = get_email_from_users(users).map{|e| { email: e }}
      response = gb.lists.batch_unsubscribe({ id: list_id, batch: emails, delete_member: true, send_goodbye: false, send_notify: false })
      failed_emails = response['errors'].map { |error| error['email']['email'] }
      successful_emails = get_email_from_users(users) - failed_emails
      update_settings_for successful_emails, { mailchimp_registered: false }
    end

    def subscription_changes_with change_type
      User.with_subscription(:newsletter, !change_type).where.not(mailchimp_registered: change_type)
    end

    def update_settings_for emails, settings
      User.where(email: emails).update_all(settings) if emails.any?
    end
end