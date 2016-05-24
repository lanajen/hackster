class Admin::PagesController < Admin::BaseController
  include FilterHelper
  include GraphHelper

  def analytics
    title "Admin / Analytics"

    @project_count = get_stat 'project_count'
    @published_project_count = get_stat 'published_project_count'
    @external_project_count = get_stat 'external_project_count'
    @waiting_for_approval_project_count = get_stat 'waiting_for_approval_project_count'
    @comment_count = get_stat 'comment_count'
    @like_count = get_stat 'like_count'
    @follow_user_count = get_stat 'follow_user_count'
    @follow_platform_count = get_stat 'follow_platform_count'
    @user_count = get_stat 'user_count'
    @messages_count = get_stat 'messages_count'
    @new_messages_count = get_stat 'new_messages_count'
    @new_projects_count = get_stat 'new_projects_count'
    @new_comments_count = get_stat 'new_comments_count'
    @new_likes_count = get_stat 'new_likes_count'
    @new_user_follows_count = get_stat 'new_user_follows_count'
    @new_platform_follows_count = get_stat 'new_platform_follows_count'
    @new_users_count = get_stat 'new_users_count'
    @active_users1d = get_stat 'active_users1d'
    @pct_active_users1d = get_stat 'pct_active_users1d'
    @active_users7d = get_stat 'active_users7d'
    @pct_active_users7d = get_stat 'pct_active_users7d'
    @active_users30d = get_stat 'active_users30d'
    @pct_active_users30d = get_stat 'pct_active_users30d'
    @project_impressions = get_stat 'project_impressions'
    @replicated_projects_count = get_stat 'replicated_projects_count'
    @owned_parts_count = get_stat 'owned_parts_count'
    @new_owned_parts_count = get_stat 'new_owned_parts_count'
    @new_replicated_projects_count = get_stat 'new_replicated_projects_count'
    @engagements_count = get_stat 'engagements_count'
    @new_engagements_count = get_stat 'new_engagements_count'

    sql = "SELECT users.*, t1.count FROM (SELECT members.user_id as user_id, COUNT(*) as count FROM members INNER JOIN groups AS team ON team.id = members.group_id INNER JOIN projects ON projects.team_id = team.id WHERE projects.private = 'f' AND projects.hide = 'f' AND projects.workflow_state = 'approved' AND (projects.guest_name = '' OR projects.guest_name IS NULL) GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 1 AND (NOT (users.roles_mask & ? > 0) OR users.roles_mask IS NULL) ORDER BY t1.count DESC LIMIT 10;"
    @heroes = User.find_by_sql([sql, 2**User::ROLES.index('admin')])

    sql = "SELECT users.*, t1.count FROM (SELECT respects.user_id as user_id, COUNT(*) as count FROM respects INNER JOIN projects ON projects.id = respects.respectable_id AND respects.respectable_type = 'BaseArticle' WHERE projects.private = 'f' AND projects.hide = 'f' AND projects.workflow_state = 'approved' AND (projects.guest_name = '' OR projects.guest_name IS NULL) GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 1 AND (NOT (users.roles_mask & ? > 0) OR users.roles_mask IS NULL) ORDER BY t1.count DESC LIMIT 10;"
    @fans = User.find_by_sql([sql, 2**User::ROLES.index('admin')])

    # keep this here for reference = how to sort by cached counters
    # sql = "SELECT * FROM (SELECT *, substring(counters_cache FROM 'live_projects_count: ([0-9]+)')::integer as live_projects_count from users) as t1 where t1.live_projects_count::integer > 1 ORDER BY live_projects_count DESC LIMIT 10;"

    # sql = "SELECT * FROM (SELECT *, substring(counters_cache FROM 'project_views_count: ([0-9]+)')::integer as project_views_count from users) as t1 where t1.project_views_count::integer > 1 ORDER BY project_views_count DESC LIMIT 10;"

    @users_with_at_least_one_live_project = User.invitation_accepted_or_not_invited.distinct.joins(:projects).where(projects: { private: false, hide: false, workflow_state: :approved }).where("projects.guest_name = '' OR projects.guest_name IS NULL").size

    sql_projects = "SELECT to_char(featured_date, 'yyyy-mm-dd') as date, COUNT(*) as count FROM projects WHERE private = 'f' AND workflow_state = 'approved' AND type = 'Project' AND date_part('days', now() - projects.featured_date) < 31 GROUP BY date ORDER BY date;"
    @new_projects = graph_with_dates_for sql_projects, 'Projects featured (approved)', 'AreaChart', Project.indexable.where("projects.featured_date < ?", 31.days.ago).count

    sql_projects = "SELECT to_char(made_public_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM projects WHERE private = 'f' AND workflow_state NOT IN ('new', 'unpublished', 'rejected') AND type = 'Project' AND date_part('days', now() - projects.made_public_at) < 31 GROUP BY date ORDER BY date;"
    @new_published_projects = graph_with_dates_for sql_projects, 'Projects published', 'AreaChart', Project.published.where("projects.made_public_at < ?", 31.days.ago).count


    sql_users = "SELECT to_char(created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM users WHERE (users.invitation_sent_at IS NULL OR users.invitation_accepted_at IS NOT NULL) AND date_part('days', now() - users.created_at) < 31 AND NOT (users.email ILIKE '%user.hackster.io') GROUP BY date ORDER BY date;"
    @new_users = graph_with_dates_for sql_users, 'New users', 'AreaChart', User.invitation_accepted_or_not_invited.not_hackster.where("users.created_at < ?", 31.days.ago).count


    sql_respects = "SELECT to_char(respects.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM respects INNER JOIN users ON users.id = respects.user_id AND NOT users.email ILIKE '%user.hackster.io' WHERE date_part('days', now() - respects.created_at) < 31 AND respects.respectable_type = 'BaseArticle' GROUP BY date ORDER BY date;"
    @new_respects = graph_with_dates_for sql_respects, 'New respects', 'AreaChart', Respect.where("respects.created_at < ?", 31.days.ago).joins(:user).where.not("users.email ILIKE '%user.hackster.io'").count


    sql_follows = "SELECT to_char(follow_relations.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM follow_relations INNER JOIN users ON users.id = follow_relations.user_id AND NOT users.email ILIKE '%user.hackster.io' WHERE date_part('days', now() - follow_relations.created_at) < 31 AND follow_relations.followable_type = 'Group' GROUP BY date ORDER BY date;"
    @new_follows = graph_with_dates_for sql_follows, 'New follows', 'AreaChart', FollowRelation.where(followable_type: 'Group').where("follow_relations.created_at < ?", 31.days.ago).joins(:user).where.not("users.email ILIKE '%user.hackster.io'").count


    sql_comments = "SELECT to_char(comments.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM comments INNER JOIN users ON users.id = comments.user_id WHERE date_part('days', now() - comments.created_at) < 31 AND comments.commentable_type = 'BaseArticle' GROUP BY date ORDER BY date;"
    @new_comments = graph_with_dates_for sql_comments, 'New comments', 'AreaChart', Comment.where(commentable_type: 'BaseArticle').where("comments.created_at < ?", 31.days.ago).joins(:user).count


    sql_respects = "SELECT to_char(respects.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM respects INNER JOIN users ON users.id = respects.user_id AND NOT users.email ILIKE '%user.hackster.io' WHERE date_part('days', now() - respects.created_at) < 31 GROUP BY date ORDER BY date;"
    sql_follows = "SELECT to_char(follow_relations.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM follow_relations INNER JOIN users ON users.id = follow_relations.user_id AND NOT users.email ILIKE '%user.hackster.io' WHERE date_part('days', now() - follow_relations.created_at) < 31 GROUP BY date ORDER BY date;"
    @new_engagements = graph_with_dates_for [sql_comments, sql_follows, sql_respects, sql_projects], 'New engagements', 'AreaChart', @engagements_count
  end

  def build_logs
    title "Admin / Project logs - #{safe_page_params}"

    @logs = BuildLog.order(created_at: :desc).paginate(page: safe_page_params)
  end

  def comments
    title "Admin / Comments - #{safe_page_params}"

    @comments = Comment.where(commentable_type: 'BaseArticle').order(created_at: :desc).paginate(page: safe_page_params)
  end

  def clear_sidekiq_failures
    Sidekiq.redis {|c| c.del('stat:failed') }
    redirect_to user_return_to, notice: 'Sidekiq failures cleared.'
  end

  def followers
    title "Admin / Followers - #{safe_page_params}"

    @fields = {
      'created_at' => 'follow_relations.created_at',
      'followable_type' => 'follow_relations.followable_type',
    }

    params[:sort_by] ||= 'created_at'

    @follow_relations = filter_for FollowRelation, @fields
  end

  def hacker_spaces
    title "Admin / Hacker Spaces - #{safe_page_params}"
    @fields = {
      'created_at' => 'groups.created_at',
      'name' => 'groups.full_name',
      'user_name' => 'groups.user_name',
    }

    params[:sort_by] ||= 'created_at'

    @groups = filter_for HackerSpace, @fields
  end

  def home
  end

  def issues
    title "Admin / Issues - #{safe_page_params}"

    @issues = Issue.where(type: 'Issue').order(created_at: :desc).paginate(page: safe_page_params)
  end

  def lists
    title "Admin / Lists - #{safe_page_params}"
    @fields = {
      'created_at' => 'groups.created_at',
      'name' => 'groups.full_name',
      'user_name' => 'groups.user_name',
      'private' => 'groups.private',
    }

    params[:sort_by] ||= 'created_at'

    @groups = filter_for List, @fields
  end

  def logs
    redirect_to admin_logs_path(page: (LogLine.count.to_f / LogLine.per_page).ceil) unless safe_page_params

    title "Admin / Logs - #{safe_page_params}"

    @fields = {
      'created_at' => 'log_lines.created_at',
      'log_type' => 'log_lines.log_type',
      'source' => 'log_lines.source',
    }

    params[:sort_order] ||= 'ASC'

    @log_lines = filter_for LogLine, @fields
  end

  def messages
    title "Admin / Messages - #{safe_page_params}"

    @comments = Comment.where(commentable_type: 'Conversation').order(created_at: :desc).paginate(page: safe_page_params)
  end

  def platforms
    title "Admin / Platforms - #{safe_page_params}"
    @fields = {
      'created_at' => 'groups.created_at',
      'name' => 'groups.full_name',
      'user_name' => 'groups.user_name',
    }

    params[:sort_by] ||= 'created_at'

    @groups = filter_for Platform, @fields
  end

  def platform_contacts
    @platforms = Platform.order(:full_name).includes(:members, members: :user)
  end

  def newsletter
    if params[:project_ids]
      @projects = BaseArticle.where(id: params[:project_ids]).most_respected
    else
      params[:sort] ||= 'respected'
      params[:by] ||= '7days'
      @projects = BaseArticle.indexable.send(BaseArticle::SORTING[params[:sort]]).send(BaseArticle::FILTERS[params[:by]])
    end
  end

  def respects
    title "Admin / Respects - #{safe_page_params}"

    @respects = Respect.where(respectable_type: 'BaseArticle').order(created_at: :desc).paginate(page: safe_page_params)
  end

  def root
  end

  def store
    @total_earned = ReputationEvent.sum(:points)
    @total_redeemable = ReputationEvent.group(:user_id).having("SUM(points) >= #{Rewardino::Event.min_redeemable_points}").sum(:points).values.sum
    @total_redeemable_month = ReputationEvent.group(:user_id).having("SUM(points) >= #{Rewardino::Event.min_redeemable_points}").sum(:points).values.map{|v| [Rewardino::Event::MAX_REDEEMABLE_MONTHLY, v].min }.sum
    @total_users = Reputation.where("redeemable_points >= #{Rewardino::Event.min_redeemable_points}").count
    @categories = ReputationEvent.group(:event_name).order("sum_points desc").sum(:points)
    @total_redeemed_month = Order.valid.where("orders.created_at > ?", Date.today.beginning_of_month).sum(:total_cost)
    @total_redeemed = Order.valid.sum(:total_cost)
    @pending_orders = Order.pending.count

    sql = "SELECT users.*, t1.sum FROM (SELECT reputation_events.user_id as user_id, SUM(reputation_events.points) as sum FROM reputation_events GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.sum > 1 AND (NOT (users.roles_mask & ? > 0) OR users.roles_mask IS NULL) ORDER BY t1.sum DESC LIMIT 10;"
    @heroes = User.find_by_sql([sql, 2**User::ROLES.index('admin')])

    sql = "SELECT to_char(event_date, 'yyyy-mm') as date, COUNT(*) as count FROM reputation_events WHERE date_part('months', now() - reputation_events.event_date) < 12 GROUP BY date ORDER BY date;"
    @chart_total_earned = graph_with_dates_for sql, 'New reputation points', 'AreaChart', ReputationEvent.where("reputation_events.event_date < ?", 12.months.ago).count, 'month'

    sql = "SELECT to_char(placed_at, 'yyyy-mm') as date, SUM(orders.total_cost) as sum FROM orders WHERE date_part('months', now() - orders.placed_at) < 12 AND orders.workflow_state NOT IN (%s) GROUP BY date ORDER BY date;"
    @chart_total_redeemed = graph_with_dates_for sql % Order::INVALID_STATES.map{|m| "'#{m}'" }.join(', '), 'Redeemed points', 'AreaChart', Order.valid.where("orders.placed_at > ?", 12.months.ago).sum(:total_cost), 'month'
  end

  private
    def analytics_redis
      @redis ||= Redis::Namespace.new('analytics', redis: RedisConn.conn)
    end

    def get_stat key
      analytics_redis.get(key).to_i
    end
end