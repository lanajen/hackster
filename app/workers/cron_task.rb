class CronTask < BaseWorker
  # @queue = :low
  sidekiq_options queue: :cron, retry: 0

  def compute_popularity
    CronTask.perform_async 'compute_popularity_for_projects'
    CronTask.perform_async 'compute_popularity_for_users'
    CronTask.perform_async 'compute_popularity_for_teches'
  end

  def compute_popularity_for_projects
    Project.indexable_and_external.pluck(:id).each do |project_id|
      CronTask.perform_async 'compute_popularity_for_project', project_id
    end
  end

  def compute_popularity_for_project project_id
    project = Project.find project_id
    project.update_counters
    project.compute_popularity
    project.save
  end

  def compute_popularity_for_users
    User.invitation_accepted_or_not_invited.pluck(:id).each do |user_id|
      CronTask.perform_async 'compute_popularity_for_user', user_id
    end
  end

  def compute_popularity_for_user user_id
    user = User.find user_id
    user.update_counters
    user.build_reputation unless user.reputation
    reputation = user.reputation
    reputation.compute
    reputation.save
  end

  def compute_popularity_for_teches
    Tech.find_each do |tech|
      tech.update_counters
    end
  end

  def expire_challenges
    Challenge.where(workflow_state: :in_progress).where("(challenges.start_date + interval '1 day' * challenges.duration) < ?", Time.now).each do |challenge|
      challenge.end!
    end
  end

  def launch_cron
    update_mailchimp_list
    send_assignment_reminder
    expire_challenges
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
    project_ids = Project.where('projects.made_public_at > ?', 24.hours.ago).where(approved: true).pluck(:id)

    users = []
    users += Tech.joins(:projects).distinct('groups.id').where(projects: { id: project_ids }).map{|t| t.followers.with_subscription('follow_tech_activity').pluck(:id) }.flatten
    users += User.joins(:projects).distinct('users.id').where(projects: { id: project_ids }).map{|u| u.followers.with_subscription('follow_user_activity').pluck(:id) }.flatten

    users.uniq!

    users.each do |user_id|
      BaseMailer.enqueue_email 'new_projects_notification', { context_type: 'daily_notification', context_id: user_id }
    end
  end

  def send_assignment_reminder
    assignments = Assignment.where("assignments.submit_by_date < ? AND assignments.reminder_sent_at IS NULL", 24.hours.from_now)
    assignments.each do |assignment|
      assignment.promotion.members.with_group_roles('student').includes(:user).each do |member|
        user = member.user
        BaseMailer.enqueue_email 'assignment_due_reminder', { context_type: 'assignment', context_id: user.id } unless user.submitted_project_to_assignment?(assignment)
      end
      assignment.update_column :reminder_sent_at, Time.now
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