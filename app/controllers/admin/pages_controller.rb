class Admin::PagesController < Admin::BaseController
  include FilterHelper
  include GraphHelper

  def analytics
    title "Admin / Analytics"

    @project_count = Project.indexable.count
    @external_project_count = Project.external.approved.count
    @waiting_for_approval_project_count = Project.public.approval_needed.count
    @comment_count = Comment.where(commentable_type: 'Project').count
    @like_count = Respect.count
    @follow_user_count = FollowRelation.where(followable_type: 'User').count
    @follow_platform_count = FollowRelation.where(followable_type: 'Group').count
    @user_count = User.invitation_accepted_or_not_invited.count
    @messages_count = Comment.where(commentable_type: 'Conversation').count
    @new_messages_count = Comment.where(commentable_type: 'Conversation').where('comments.created_at > ?', Date.today).count
    @new_projects_count = Project.indexable.where('projects.made_public_at > ?', Date.today).count
    @new_comments_count = Comment.where(commentable_type: 'Project').where('comments.created_at > ?', Date.today).count
    @new_likes_count = Respect.where('respects.created_at > ?', Date.today).count
    @new_user_follows_count = FollowRelation.where(followable_type: 'User').where('follow_relations.created_at > ?', Date.today).count
    @new_platform_follows_count = FollowRelation.where(followable_type: 'Group').where('follow_relations.created_at > ?', Date.today).count
    @new_users_count = User.invitation_accepted_or_not_invited.where('users.created_at > ?', Date.today).count
    new_users1d = User.invitation_accepted_or_not_invited.where("users.created_at > ?", 1.days.ago).count
    new_users7d = User.invitation_accepted_or_not_invited.where("users.created_at > ?", 7.days.ago).count
    new_users30d = User.invitation_accepted_or_not_invited.where("users.created_at > ?", 30.days.ago).count
    @active_users1d = User.where("users.last_seen_at > ?", 1.days.ago).count - new_users1d
    @active_users7d = User.where("users.last_seen_at > ?", 7.days.ago).count - new_users7d
    @active_users30d = User.where("users.last_seen_at > ?", 30.days.ago).count - new_users30d
    @project_impressions = Impression.where(impressionable_type: 'Project').count

    sql = "SELECT users.*, t1.count FROM (SELECT members.user_id as user_id, COUNT(*) as count FROM members INNER JOIN groups AS team ON team.id = members.group_id INNER JOIN projects ON projects.team_id = team.id WHERE projects.private = 'f' AND projects.hide = 'f' AND projects.workflow_state = 'approved' AND (projects.guest_name = '' OR projects.guest_name IS NULL) GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 1 AND (NOT (users.roles_mask & ? > 0) OR users.roles_mask IS NULL) ORDER BY t1.count DESC LIMIT 10;"
    @heroes = User.find_by_sql([sql, 2**User::ROLES.index('admin')])

    sql = "SELECT users.*, t1.count FROM (SELECT respects.user_id as user_id, COUNT(*) as count FROM respects INNER JOIN projects ON projects.id = respects.respectable_id AND respects.respectable_type = 'Project' WHERE projects.private = 'f' AND projects.hide = 'f' AND projects.workflow_state = 'approved' AND (projects.guest_name = '' OR projects.guest_name IS NULL) GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 1 AND (NOT (users.roles_mask & ? > 0) OR users.roles_mask IS NULL) ORDER BY t1.count DESC LIMIT 10;"
    @fans = User.find_by_sql([sql, 2**User::ROLES.index('admin')])

    # keep this here for reference = how to sort by cached counters
    # sql = "SELECT * FROM (SELECT *, substring(counters_cache FROM 'live_projects_count: ([0-9]+)')::integer as live_projects_count from users) as t1 where t1.live_projects_count::integer > 1 ORDER BY live_projects_count DESC LIMIT 10;"

    # sql = "SELECT * FROM (SELECT *, substring(counters_cache FROM 'project_views_count: ([0-9]+)')::integer as project_views_count from users) as t1 where t1.project_views_count::integer > 1 ORDER BY project_views_count DESC LIMIT 10;"

    @users_with_at_least_one_live_project = User.invitation_accepted_or_not_invited.distinct.joins(:projects).where(projects: { private: false, hide: false, workflow_state: :approved }).where("projects.guest_name = '' OR projects.guest_name IS NULL").size

    sql = "SELECT to_char(made_public_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM projects WHERE private = 'f' AND hide = 'f' AND date_part('days', now() - projects.made_public_at) < 31 GROUP BY date ORDER BY date;"
    @new_projects = graph_with_dates_for sql, 'Projects made public', 'AreaChart', Project.where(private: false, hide: false).where("projects.made_public_at < ?", 31.days.ago).count

    sql = "SELECT to_char(created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM users WHERE (users.invitation_sent_at IS NULL OR users.invitation_accepted_at IS NOT NULL) AND date_part('days', now() - users.created_at) < 31 GROUP BY date ORDER BY date;"
    @new_users = graph_with_dates_for sql, 'New users', 'AreaChart', User.invitation_accepted_or_not_invited.where("users.created_at < ?", 31.days.ago).count


    sql = "SELECT to_char(created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM respects WHERE date_part('days', now() - respects.created_at) < 31 GROUP BY date ORDER BY date;"
    @new_respects = graph_with_dates_for sql, 'New respects', 'AreaChart', Respect.where("respects.created_at < ?", 31.days.ago).count


    sql = "SELECT to_char(created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM follow_relations WHERE date_part('days', now() - follow_relations.created_at) < 31 AND follow_relations.followable_type = 'Group' GROUP BY date ORDER BY date;"
    @new_follows = graph_with_dates_for sql, 'New follows', 'AreaChart', FollowRelation.where(followable_type: 'Group').where("follow_relations.created_at < ?", 31.days.ago).count
  end

  def build_logs
    title "Admin / Build logs - #{safe_page_params}"

    @logs = BuildLog.order(created_at: :desc).paginate(page: safe_page_params)
  end

  def comments
    title "Admin / Comments - #{safe_page_params}"

    @comments = Comment.where(commentable_type: 'Project').order(created_at: :desc).paginate(page: safe_page_params)
  end

  def clear_sidekiq_failures
    Sidekiq.redis {|c| c.del('stat:failed') }
    redirect_to user_return_to, notice: 'Sidekiq failures cleared.'
  end

  def followers
    title "Admin / Followers - #{safe_page_params}"

    @follow_relations = FollowRelation.order(created_at: :desc).paginate(page: safe_page_params)
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

  def issues
    title "Admin / Issues - #{safe_page_params}"

    @issues = Issue.where(type: 'Issue').order(created_at: :desc).paginate(page: safe_page_params)
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

  def newsletter
    if params[:project_ids]
      @projects = Project.where(id: params[:project_ids]).most_respected
    else
      params[:sort] ||= 'respected'
      params[:by] ||= '7days'
      @projects = Project.indexable.send(Project::SORTING[params[:sort]]).send(Project::FILTERS[params[:by]])
    end
  end

  def respects
    title "Admin / Respects - #{safe_page_params}"

    @respects = Respect.where(respectable_type: 'Project').order(created_at: :desc).paginate(page: safe_page_params)
  end

  def root
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
end