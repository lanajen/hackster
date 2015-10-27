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
    BaseArticle.indexable_and_external.select(:id).find_each do |project|
      self.class.perform_async 'compute_popularity_for_project', project.id, defaults
    end
  end

  def compute_popularity_for_project project_id, defaults={}
    project = BaseArticle.find project_id
    project.update_counters

    count = ProjectPopularityCounter.new(project, defaults).adjusted_score
    project.update_column :popularity_counter, count
  end

  def compute_popularity_for_users
    User.invitation_accepted_or_not_invited.select(:id).find_each do |user|
      self.class.perform_async 'compute_popularity_for_user', user.id
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