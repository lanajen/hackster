class PopularityWorker < BaseWorker
  sidekiq_options queue: :cron, retry: 3

  def compute_popularity
    self.class.perform_async 'compute_popularity_for_users'
    self.class.perform_async 'compute_popularity_for_platforms'
  end

  def compute_popularity_for_projects
    defaults = {
      median_impressions: BaseArticle.median_impressions,
      median_respects: BaseArticle.median_respects,
    }
    time = Time.now  # throttle updates to give the DB more breathing room
    BaseArticle.indexable_and_external.select(:id).find_each do |project|
      self.class.perform_at time, 'compute_popularity_for_project', project.id, defaults
      time += (1.second.to_f / 4)  # 4 per second =~ 10 minutes to compute 3k records
    end
  end

  def compute_popularity_for_project project_id, defaults={}
    project = BaseArticle.find project_id
    project.update_counters only: [:comments, :real_respects]

    count = ProjectPopularityCounter.new(project, defaults).adjusted_score
    project.update_column :popularity_counter, count
  end

  def compute_popularity_for_users
    time = Time.now  # throttle updates to give the DB more breathing room
    User.invitation_accepted_or_not_invited.not_hackster.select(:id).find_each do |user|
      self.class.perform_at time, 'compute_popularity_for_user', user.id
      time += (1.second.to_f / 10)  # 10 per second =~ 10 minutes to compute 70k records
    end
  end

  def compute_popularity_for_user user_id
    user = User.find user_id
    user.update_counters only: [:live_projects, :live_hidden_projects, :followers, :project_respects, :project_views]
    user.build_reputation unless user.reputation
    reputation = user.reputation
    reputation.compute
    reputation.save
  end

  def compute_popularity_for_platforms
    Platform.find_each do |platform|
      platform.update_counters only: [:projects, :members, :parts]
    end
  end
end