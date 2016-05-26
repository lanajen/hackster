class AnalyticsWorker < BaseWorker
  sidekiq_options queue: :low, retry: 1

  def cache_stats
    set_stat 'project_count', Project.indexable.count
    set_stat 'published_project_count', Project.published.count
    set_stat 'external_project_count', ExternalProject.approved.count
    set_stat 'waiting_for_approval_project_count', BaseArticle.need_review.count
    set_stat 'comment_count', Comment.where(commentable_type: 'BaseArticle').count
    set_stat 'like_count', Respect.joins(:user).where.not("users.email ILIKE '%user.hackster.io'").count
    set_stat 'follow_user_count', FollowRelation.where(followable_type: 'User').joins(:user).where.not("users.email ILIKE '%user.hackster.io'").count
    set_stat 'follow_platform_count', FollowRelation.where(followable_type: 'Group').joins(:user).where.not("users.email ILIKE '%user.hackster.io'").count
    user_count = User.invitation_accepted_or_not_invited.not_hackster.count
    set_stat 'user_count', user_count
    set_stat 'messages_count', Comment.where(commentable_type: 'Conversation').count
    set_stat 'new_messages_count', Comment.where(commentable_type: 'Conversation').where('comments.created_at > ?', Date.today).count
    set_stat 'new_projects_count', BaseArticle.indexable.where('projects.made_public_at > ?', Date.today).count
    set_stat 'new_comments_count', Comment.where(commentable_type: 'BaseArticle').where('comments.created_at > ?', Date.today).count
    set_stat 'new_likes_count', Respect.where('respects.created_at > ?', Date.today).count
    set_stat 'new_user_follows_count', FollowRelation.where(followable_type: 'User').where('follow_relations.created_at > ?', Date.today).joins(:user).where.not("users.email ILIKE '%user.hackster.io'").count
    set_stat 'new_platform_follows_count', FollowRelation.where(followable_type: 'Group').where('follow_relations.created_at > ?', Date.today).joins(:user).where.not("users.email ILIKE '%user.hackster.io'").count
    set_stat 'new_users_count', User.invitation_accepted_or_not_invited.not_hackster.where('users.created_at > ?', Date.today).count
    max_date = Date.yesterday.end_of_day
    new_users1d = User.invitation_accepted_or_not_invited.not_hackster.where("users.created_at > ? AND users.created_at < ?", max_date - 1.day, max_date).count
    new_users7d = User.invitation_accepted_or_not_invited.not_hackster.where("users.created_at > ? AND users.created_at < ?", max_date - 7.days, max_date).count
    new_users30d = User.invitation_accepted_or_not_invited.not_hackster.where("users.created_at > ? AND users.created_at < ?", max_date - 30.days, max_date).count
    set_stat 'active_users1d', User.where("users.last_seen_at > ? AND users.last_seen_at < ?", max_date - 1.day, max_date).count - new_users1d
    set_stat 'active_users7d', User.where("users.last_seen_at > ? AND users.last_seen_at < ?", max_date - 7.days, max_date).count - new_users7d
    set_stat 'active_users30d', User.where("users.last_seen_at > ? AND users.last_seen_at < ?", max_date - 30.days, max_date).count - new_users30d
    set_stat 'project_impressions', ProjectImpression.count
    set_stat 'replicated_projects_count', FollowRelation.where(followable_type: 'BaseArticle').count
    set_stat 'owned_parts_count', FollowRelation.where(followable_type: 'Part').count
    set_stat 'new_owned_parts_count', FollowRelation.where(followable_type: 'Part').where('follow_relations.created_at > ?', Date.today).count
    set_stat 'new_replicated_projects_count', FollowRelation.where(followable_type: 'BaseArticle').where('follow_relations.created_at > ?', Date.today).count
    set_stat 'engagements_count', Comment.where(commentable_type: %w(BaseArticle)).count + BaseArticle.own.count + Respect.joins(:user).where.not("users.email ILIKE '%user.hackster.io'").count + FollowRelation.joins(:user).where.not("users.email ILIKE '%user.hackster.io'").count
    set_stat 'new_engagements_count', Comment.where(commentable_type: %w(BaseArticle)).where('comments.created_at > ?', Date.today).count + BaseArticle.own.where('projects.created_at > ?', Date.today).count + Respect.joins(:user).where.not("users.email ILIKE '%user.hackster.io'").where('respects.created_at > ?', Date.today).count + FollowRelation.joins(:user).where.not("users.email ILIKE '%user.hackster.io'").where('follow_relations.created_at > ?', Date.today).count
  end

  private
    def redis
      @redis ||= Redis::Namespace.new('analytics', redis: RedisConn.conn)
    end

    def set_stat key, val
      redis.set key, val
    end
end