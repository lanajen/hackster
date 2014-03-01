class Admin::PagesController < Admin::BaseController
  include FilterHelper
  include GraphHelper

  def analytics
    title "Admin > Analytics"

    @project_count = Project.indexable.count
    @comment_count = Comment.count
    @like_count = Favorite.count
    @follow_count = FollowRelation.count
    @user_count = User.invitation_accepted_or_not_invited.count
    @new_projects_count = Project.indexable.where('projects.made_public_at > ?', Date.today).count
    @new_comments_count = Comment.where('comments.created_at > ?', Date.today).count
    @new_likes_count = Favorite.where('favorites.created_at > ?', Date.today).count
    @new_follows_count = FollowRelation.where('follow_relations.created_at > ?', Date.today).count
    @new_users_count = User.invitation_accepted_or_not_invited.where('users.created_at > ?', Date.today).count

    sql = "SELECT users.* FROM (SELECT members.user_id as user_id, COUNT(*) as count FROM members INNER JOIN groups ON groups.id = members.group_id INNER JOIN projects ON projects.team_id = groups.id WHERE projects.private = 'f' GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 1 ORDER BY t1.count DESC LIMIT 10;"

    # sql = "SELECT * FROM (SELECT *, substring(counters_cache FROM 'live_projects_count: ([0-9]+)') as live_projects_count from users) as t1 where t1.live_projects_count::integer > 1 ORDER BY live_projects_count DESC LIMIT 10;"

    @top_users = User.find_by_sql(sql)

    @users_with_at_least_one_live_project = User.invitation_accepted_or_not_invited.joins(:projects).distinct.where(projects: { private: false }).size


    sql = "SELECT to_char(made_public_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM projects WHERE private = 'f' AND hide = 'f' AND date_part('days', now() - projects.made_public_at) < 30 GROUP BY date ORDER BY date;"
    @new_projects = graph_with_dates_for sql, 'Projects made public', 'ColumnChart'


    sql = "SELECT to_char(created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM users WHERE (users.invitation_sent_at IS NULL OR users.invitation_accepted_at IS NOT NULL) AND date_part('days', now() - users.created_at) < 30 GROUP BY date ORDER BY date;"
    @new_users = graph_with_dates_for sql, 'New users', 'ColumnChart'


    sql = "SELECT to_char(created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM comments WHERE date_part('days', now() - comments.created_at) < 30 GROUP BY date ORDER BY date;"
    @new_comments = graph_with_dates_for sql, 'New comments', 'ColumnChart'


    sql = "SELECT to_char(created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM favorites WHERE date_part('days', now() - favorites.created_at) < 30 GROUP BY date ORDER BY date;"
    @new_respects = graph_with_dates_for sql, 'New respects', 'ColumnChart'
  end

  def comments
    title "Admin > Comments - #{params[:page]}"

    @comments = Comment.order(created_at: :desc).paginate(page: params[:page])
  end

  def followers
    title "Admin > Followers - #{params[:page]}"

    @follow_relations = FollowRelation.order(created_at: :desc).paginate(page: params[:page])
  end

  def logs
    redirect_to admin_logs_path(page: (LogLine.count.to_f / LogLine.per_page).ceil) unless params[:page]

    title "Admin > Logs - #{params[:page]}"

    @fields = {
      'created_at' => 'log_lines.created_at',
      'log_type' => 'log_lines.log_type',
      'source' => 'log_lines.source',
    }

    params[:sort_order] ||= 'ASC'

    @log_lines = filter_for LogLine, @fields
  end

  def respects
    title "Admin > Respects - #{params[:page]}"

    @respects = Favorite.order(created_at: :desc).paginate(page: params[:page])
  end

  def root
  end
end