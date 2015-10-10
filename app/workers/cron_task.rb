class CronTask < BaseWorker
  # @queue = :low
  sidekiq_options queue: :cron, retry: 0

  def add_missing_parts_to_users_toolbox
    User.not_hackster.user_name_set.each do |user|
      CronTask.perform_async 'add_missing_parts_to_user_toolbox', user.id
    end
  end

  def add_missing_parts_to_user_toolbox id
    return unless user = User.find_by_id id

    user.parts_missing_from_toolbox.each do |part|
      user.owned_parts << part
    end
  end

  def cleanup_duplicates
    ProjectCollection.select("id, count(id) as quantity").group(:project_id, :collectable_id, :collectable_type).having("count(id) > 1").size.each do |c, count|
      ProjectCollection.where(:project_id => c[0], :collectable_id => c[1], :collectable_type => c[2]).limit(count-1).each{|cp| cp.delete }
      Group.find(c[1]).update_counters only: [:projects]
    end

    CoverImage.select("id, count(id) as quantity").where("attachable_type = 'Project'").group(:attachable_id, :attachable_type).having("count(id) > 1").size.each do |c, count|
      pid = c[0]
      CoverImage.where(attachable_id: pid, attachable_type: 'Project').order(created_at: :asc).limit(count - 1).each{|cp| cp.delete }
    end
  end

  def cleanup_buggy_unpublished
    Project.public.self_hosted.where(workflow_state: :unpublished).where(made_public_at: nil).update_all(workflow_state: :pending_review)
    Project.public.self_hosted.where(workflow_state: :unpublished).where.not(made_public_at: nil).each do |project|
      project.update_attribute :workflow_state, :approved
    end
  end

  def clean_invitations
    User.where.not(invitation_token: nil).where.not(last_sign_in_at: nil).update_all(invitation_token: nil)
  end

  def evaluate_badges
    return unless Rewardino.activated?

    triggers = Rewardino::Trigger.find_all :cron
    badges = triggers.map{|t| t.badge }
    User.invitation_accepted_or_not_invited.each do |user|
      badges.each do |badge|
        User.delay.evaluate_badge user.id, badge.code, send_notification: true
      end
    end
  end

  def generate_user
    UserGenerator.generate_user
  rescue => e
  end

  def generate_users
    [User.invitation_accepted_or_not_invited.where("created_at > ?", 1.day.ago).where.not("users.email ILIKE '%user.hackster.io'").size, 25].min.times do
      CronTask.perform_at Time.at((1.day.from_now.to_f - Time.now.to_f)*rand + Time.now.to_f), 'generate_user'
    end
  end

  def launch_cron
    CacheWorker.perform_async 'warm_cache'
    CronTask.perform_in 3.minutes, 'cleanup_buggy_unpublished'
    CronTask.perform_in 3.minutes, 'lock_assignment'
    CronTask.perform_in 4.minutes, 'send_assignment_reminder'
    CronTask.perform_in 6.minutes, 'send_announcement_notifications'
    CronTask.perform_in 8.minutes, 'cleanup_duplicates'
    CronTask.perform_in 10.minutes, 'clean_invitations'
    PopularityWorker.perform_in 12.minutes, 'compute_popularity_for_projects'
    CronTask.perform_in 14.minutes, 'evaluate_badges'
  end

  def launch_daily_cron
    CronTask.perform_async 'generate_users'
    CronTask.perform_async 'update_mailchimp'
    CronTask.perform_async 'update_mailchimp_for_challenges'
    CronTask.perform_async 'send_challenge_reminder'
    ReputationWorker.perform_in 1.minute, 'compute_daily_reputation'
    PopularityWorker.perform_in 1.hour, 'compute_popularity'
    CronTask.perform_in 1.5.hours, 'add_missing_parts_to_users_toolbox'
    CronTask.perform_in 2.hours, 'send_daily_notifications'
  end

  def launch_weekly_cron
    CronTask.perform_async 'send_weekly_notifications'

    # monthly cron on first Monday
    if Date.today.day.in? (1..7)
      CronTask.perform_async 'launch_monthly_cron'
    end
  end

  def launch_monthly_cron
    CronTask.perform_async 'send_monthly_notifications'
  end

  def lock_assignment
    Assignment.pending_grading.each do |assignment|
      assignment.projects.submitted.each do |project|
        project.update_attribute :locked, true
      end
    end
  rescue => e
  end

  def send_daily_notifications
    send_project_notifications 24.hours, :daily
  end

  def send_weekly_notifications
    send_project_notifications 7.days, :weekly
  end

  def send_monthly_notifications
    send_project_notifications 1.month, :monthly
  end

  def send_announcement_notifications
    Announcement.published.not_sent.each do |announcement|
      NotificationCenter.notify_all :new, :announcement, announcement.id
      announcement.workflow_state = 'sent'
      announcement.save
    end
  end

  def send_assignment_reminder
    assignments = Assignment.where("assignments.submit_by_date < ? AND assignments.reminder_sent_at IS NULL", 24.hours.from_now)
    assignments.each do |assignment|
      assignment.promotion.members.with_group_roles('student').includes(:user).each do |member|
        user = member.user
        NotificationCenter.notify_all :due, :assignment, user.id unless user.submitted_project_to_assignment?(assignment)
      end
      assignment.update_column :reminder_sent_at, Time.now
    end
  end

  def send_challenge_reminder
    Challenge::REMINDER_TIMES.each do |time|
      # pre-contest
      challenges = Challenge.where("CAST(challenges.hproperties -> 'activate_pre_contest' AS BOOLEAN) = 't' AND CAST(challenges.hproperties -> 'pre_contest_end_date' AS INTEGER) < ? AND CAST(challenges.hproperties -> 'pre_contest_end_date' AS INTEGER) > ?", time.from_now.to_i, (time.from_now - 1.day).to_i)

      challenges.each do |challenge|
        NotificationCenter.notify_all :ending_soon, :challenge, challenge.id, 'pre_contest_ending_soon'
      end

      # contest
      challenges = Challenge.where("challenges.end_date < ? AND challenges.end_date > ?", time.from_now, time.from_now - 1.day)

      challenges.each do |challenge|
        NotificationCenter.notify_all :ending_soon, :challenge, challenge.id
      end
    end
  end

  def update_mailchimp
    MailchimpNewsletterListManager.new(ENV['MAILCHIMP_API_KEY'], ENV['MAILCHIMP_LIST_ID']).update!
  end

  def update_mailchimp_for_challenges
    Challenge.where("challenges.end_date > ?", 1.day.ago).each do |challenge|
      challenge.sync_mailchimp! if challenge.mailchimp_setup?
    end
  end

  private
    def redis
      @redis ||= Redis::Namespace.new('cron_task', redis: RedisConn.conn)
    end

    def send_project_notifications time_frame, email_frequency
      project_ids = Project.self_hosted.where('projects.made_public_at > ? AND projects.made_public_at < ?', time_frame.ago, Time.now).approved.pluck(:id)

      users = []

      # platform followers
      users += Platform.joins(:projects).distinct('groups.id').where(projects: { id: project_ids }).map{|t| t.followers.with_subscription(:email, 'new_projects').with_email_frequency(email_frequency).pluck(:id) }.flatten

      # user followers
      users += User.joins(:projects).distinct('users.id').where(projects: { id: project_ids }).map{|u| u.followers.with_subscription(:email, 'new_projects').with_email_frequency(email_frequency).pluck(:id) }.flatten

      # list followers
      lists = List.joins(:project_collections).where('project_collections.created_at > ?', time_frame.ago).where(groups: { type: 'List' }).distinct(:id)
      users += lists.map{|l| l.followers.with_subscription(:email, 'new_projects').with_email_frequency(email_frequency).pluck(:id) }.flatten

      # part owners
      users += Part.joins(:projects).distinct('parts.id').where.not(parts: { platform_id: nil }).where(projects: { id: project_ids }).map{|p| p.owners.with_subscription(:email, 'new_projects').with_email_frequency(email_frequency).pluck(:id) }.flatten

      users.uniq!

      users.each do |user_id|
        NotificationCenter.notify_via_email nil, "#{email_frequency}_notification", user_id, 'new_projects'
      end
    end
end