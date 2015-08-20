class PopularityWorker < BaseWorker
  sidekiq_options queue: :cron, retry: 3

  def compute_popularity
    self.class.perform_async 'compute_popularity_for_users'
    self.class.perform_async 'compute_popularity_for_platforms'
  end

  def compute_popularity_for_projects
    defaults = {
      median_impressions: Project.median_impressions,
      median_respects: Project.median_respects,
    }
    Project.indexable_and_external.pluck(:id).each do |project_id|
      self.class.perform_async 'compute_popularity_for_project', project_id, defaults
    end
  end

  def compute_popularity_for_project project_id, defaults={}
    project = Project.find project_id
    project.update_counters

    count = ProjectPopularityCounter.new(project, defaults).adjusted_score
    project.update_column :popularity_counter, count
  end

  def compute_popularity_for_users
    User.invitation_accepted_or_not_invited.pluck(:id).each do |user_id|
      self.class.perform_async 'compute_popularity_for_user', user_id
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

  def compute_popularity_for_platforms
    Platform.find_each do |platform|
      platform.update_counters
    end
  end
end