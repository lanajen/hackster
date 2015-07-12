class CronTask < BaseWorker
  # @queue = :low
  sidekiq_options queue: :cron, retry: 0

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

  def clean_invitations
    User.where.not(invitation_token: nil).where.not(last_sign_in_at: nil).update_all(invitation_token: nil)
  end

  def compute_popularity
    CronTask.perform_async 'compute_popularity_for_projects'
    CronTask.perform_async 'compute_popularity_for_users'
    CronTask.perform_async 'compute_popularity_for_platforms'
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
    reputation.compute_redeemable
    reputation.save
  end

  def compute_popularity_for_platforms
    Platform.find_each do |platform|
      platform.update_counters
    end
  end

  def compute_reputation user_id, date=nil
    date = Time.at(date.to_i) if date
    Rewardino::Event.compute_for_user user_id, date
  end

  def compute_daily_reputation
    date = redis.get('last_update')
    # date = Time.at(date.to_i) if date.present?
    User.invitation_accepted_or_not_invited.find_each do |user|
      CronTask.perform_async 'compute_reputation', user.id, date.presence
    end
    redis.set 'last_update', Time.now.to_i
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

  def expire_challenges
    Challenge.where(workflow_state: :in_progress).where("challenges.end_date < ?", Time.now).each do |challenge|
      challenge.end!
    end
  end

  def generate_user
    UserGenerator.generate_user
  end

  def generate_users
    User.invitation_accepted_or_not_invited.where("created_at > ?", 1.day.ago).where.not("users.email ILIKE '%user.hackster.io'").size.times do
      CronTask.perform_at Time.at((1.day.from_now.to_f - Time.now.to_f)*rand + Time.now.to_f), 'generate_user'
    end
  end

  def launch_cron
    CacheWorker.perform_async 'warm_cache'
    CronTask.perform_async 'update_mailchimp'
    CronTask.perform_async 'send_assignment_reminder'
    CronTask.perform_async 'lock_assignment'
    CronTask.perform_async 'expire_challenges'
    CronTask.perform_async 'evaluate_badges'
    CronTask.perform_async 'send_announcement_notifications'
    CronTask.perform_async 'cleanup_duplicates'
    CronTask.perform_async 'clean_invitations'
  end

  def launch_daily_cron
    self.class.perform_async 'compute_daily_reputation'
    self.class.perform_in 1.hour, 'compute_popularity'
    self.class.perform_in 2.hours, 'send_daily_notifications'
    self.class.perform_in 24.hours, 'launch_daily_cron'
    self.class.perform_async 'generate_users'

    self.class.perform_in 24.hours, 'launch_daily_cron'
  end

  def lock_assignment
    Assignment.where("assignments.submit_by_date < ?", Time.now).each do |assignment|
      assignment.projects.each do |project|
        project.locked = true
        project.save
      end
    end
  end

  def send_daily_notifications
    project_ids = Project.self_hosted.where('projects.made_public_at > ? AND projects.made_public_at < ?', 24.hours.ago, Time.now).approved.pluck(:id)

    users = []
    users += Platform.joins(:projects).distinct('groups.id').where(projects: { id: project_ids }).map{|t| t.followers.with_subscription(:email, 'follow_platform_activity').pluck(:id) }.flatten
    users += User.joins(:projects).distinct('users.id').where(projects: { id: project_ids }).map{|u| u.followers.with_subscription(:email, 'follow_user_activity').pluck(:id) }.flatten

    lists = List.joins(:project_collections).where('project_collections.created_at > ?', 24.hours.ago).where(groups: { type: 'List' }).distinct(:id)
    users += lists.map{|l| l.followers.with_subscription(:email, 'follow_list_activity').pluck(:id) }.flatten

    users.uniq!

    users.each do |user_id|
      NotificationCenter.notify_via_email nil, 'daily_notification', user_id, 'new_projects'
    end
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

  def update_mailchimp
    MailchimpListManager.new(ENV['MAILCHIMP_API_KEY'], ENV['MAILCHIMP_LIST_ID']).update!
  end

  private
    def redis
      @redis ||= Redis::Namespace.new('cron_task', redis: Redis.new($redis_config))
    end
end