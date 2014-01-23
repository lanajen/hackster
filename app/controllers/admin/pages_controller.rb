class Admin::PagesController < Admin::BaseController
  include FilterHelper
  include GraphHelper

  def analytics
    @project_count = Project.live.count
    @comment_count = Comment.count
    @like_count = Favorite.count
    @user_count = User.invitation_accepted_or_not_invited.count

    sql = "SELECT users.* FROM (SELECT members.user_id as user_id, COUNT(*) as count FROM members INNER JOIN groups ON groups.id = members.group_id INNER JOIN projects ON projects.team_id = groups.id WHERE projects.private = 'f' GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 1 ORDER BY t1.count DESC LIMIT 10;"

    # sql = "SELECT * FROM (SELECT *, substring(counters_cache FROM 'live_projects_count: ([0-9]+)') as live_projects_count from users) as t1 where t1.live_projects_count::integer > 1 ORDER BY live_projects_count DESC LIMIT 10;"

    @top_users = User.find_by_sql(sql)

    sql = "SELECT COUNT(*) as count FROM (SELECT COUNT(*) as live_projects_count FROM members INNER JOIN groups ON groups.id = members.group_id INNER JOIN projects ON projects.team_id = groups.id WHERE projects.private = 'f' GROUP BY user_id) as t1;"

    records_array = ActiveRecord::Base.connection.execute(sql)

    @users_with_at_least_one_live_project = records_array[0]['count']


    sql = "SELECT to_char(made_public_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM projects WHERE private = 'f' AND date_part('days', now() - projects.made_public_at) < 30 GROUP BY date ORDER BY date;"
    records_array = ActiveRecord::Base.connection.exec_query(sql)

    rows = records_array.rows.map do |row|
      [Date.parse("#{row[0]}"), row[1].to_i]
    end

    columns = [['date', 'Day'], ['number', 'Total']]
    @new_projects = graph rows, columns, 'Projects made public', 'ColumnChart'


    sql = "SELECT to_char(created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM users WHERE (users.invitation_sent_at IS NULL OR users.invitation_accepted_at IS NOT NULL) AND date_part('days', now() - users.created_at) < 30 GROUP BY date ORDER BY date;"
    records_array = ActiveRecord::Base.connection.exec_query(sql)

    rows = records_array.rows.map do |row|
      [Date.parse("#{row[0]}"), row[1].to_i]
    end

    columns = [['date', 'Day'], ['number', 'Total']]
    @new_users = graph rows, columns, 'New users', 'ColumnChart'


    sql = "SELECT to_char(created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM comments WHERE date_part('days', now() - comments.created_at) < 30 GROUP BY date ORDER BY date;"
    records_array = ActiveRecord::Base.connection.exec_query(sql)

    rows = records_array.rows.map do |row|
      [Date.parse("#{row[0]}"), row[1].to_i]
    end

    columns = [['date', 'Day'], ['number', 'Total']]
    @new_comments = graph rows, columns, 'New comments', 'ColumnChart'


    sql = "SELECT to_char(created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM favorites WHERE date_part('days', now() - favorites.created_at) < 30 GROUP BY date ORDER BY date;"
    records_array = ActiveRecord::Base.connection.exec_query(sql)

    rows = records_array.rows.map do |row|
      [Date.parse("#{row[0]}"), row[1].to_i]
    end

    columns = [['date', 'Day'], ['number', 'Total']]
    @new_respects = graph rows, columns, 'New respects', 'ColumnChart'
  end

  def comments
    @comments = Comment.order(created_at: :desc).paginate(page: params[:page])
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
    @respects = Favorite.order(created_at: :desc).paginate(page: params[:page])
  end

  def root
  end
end