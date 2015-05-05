module PlatformHelper
  def load_analytics

    @project_count = @platform.projects_count
    @external_project_count = @platform.projects.visible.external.approved.count
    @comment_count = @platform.projects.joins(:comments).count
    @like_count = @platform.projects.joins(:respects).count
    @follow_count = @platform.followers_count
    @views_count = @platform.impressions.count
    @project_views_count = @platform.projects.joins(:impressions).count
    @new_projects_count = @platform.projects.visible.indexable_and_external.where('projects.made_public_at > ?', Date.today).count
    @new_comments_count = @platform.projects.joins(:comments).where('comments.created_at > ?', Date.today).count
    @new_likes_count = @platform.projects.joins(:respects).where('respects.created_at > ?', Date.today).count
    @new_follows_count = @platform.followers.where('follow_relations.created_at > ?', Date.today).count
    @new_views_count = @platform.impressions.where('impressions.created_at > ?', Date.today).count
    @new_project_views_count = @platform.projects.joins(:impressions).where('impressions.created_at > ?', Date.today).count

    sql = "SELECT users.*, t1.count FROM (SELECT members.user_id as user_id, COUNT(*) as count FROM members INNER JOIN groups AS team ON team.id = members.group_id INNER JOIN projects ON projects.team_id = team.id INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? AND projects.private = 'f' AND projects.hide = 'f' AND projects.workflow_state = 'approved' AND (projects.guest_name = '' OR projects.guest_name IS NULL) GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 1 ORDER BY t1.count DESC LIMIT 10;"
    @heroes = User.find_by_sql([sql, @platform.id])

    sql = "SELECT users.*, t1.count FROM (SELECT respects.user_id as user_id, COUNT(*) as count FROM respects INNER JOIN projects ON projects.id = respects.respectable_id AND respects.respectable_type = 'Project' INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE project_collections.collectable_type = 'Group' AND projects.private = 'f' AND projects.hide = 'f' AND projects.workflow_state = 'approved' AND (projects.guest_name = '' OR projects.guest_name IS NULL) AND project_collections.collectable_id = ? GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 1 AND (NOT (users.roles_mask & ? > 0) OR users.roles_mask IS NULL) ORDER BY t1.count DESC LIMIT 10;"
    @fans = User.find_by_sql([sql, @platform.id, 2**User::ROLES.index('admin')])

    sql = "SELECT projects.*, t1.count FROM (SELECT respects.respectable_id as project_id, COUNT(*) as count FROM respects INNER JOIN project_collections ON project_collections.project_id = respects.respectable_id WHERE respects.respectable_type = 'Project' AND project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? GROUP BY respects.respectable_id) AS t1 INNER JOIN projects ON projects.id = t1.project_id WHERE t1.count > 1 AND projects.private = 'f' AND projects.workflow_state = 'approved' ORDER BY t1.count DESC LIMIT 10;"
    @most_respected_projects = Project.find_by_sql([sql, @platform.id])

    sql = "SELECT projects.*, t1.count FROM (SELECT impressions.impressionable_id as project_id, COUNT(*) as count FROM impressions INNER JOIN project_collections ON project_collections.project_id = impressions.impressionable_id WHERE project_collections.collectable_type = 'Group' AND impressions.impressionable_type = 'Project' AND project_collections.collectable_id = ? GROUP BY impressions.impressionable_id) AS t1 INNER JOIN projects ON projects.id = t1.project_id WHERE t1.count > 1 AND projects.private = 'f' AND projects.workflow_state = 'approved' ORDER BY t1.count DESC LIMIT 10;"
    @most_viewed_projects = Project.find_by_sql([sql, @platform.id])

    @most_recent_projects = @platform.projects.visible.indexable_and_external.joins(:users).order(made_public_at: :desc).distinct("projects.id").limit(3)

    sql = "SELECT comments.* FROM comments INNER JOIN projects ON comments.commentable_id = projects.id INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE comments.commentable_type = 'Project' AND project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? ORDER BY comments.created_at DESC LIMIT 3"
    @most_recent_comments = Comment.find_by_sql [sql, @platform.id]

    @most_recent_followers = @platform.follow_relations.order(created_at: :desc).limit(10)

    @new_projects_sql = "SELECT to_char(projects.made_public_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM projects INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE project_collections.collectable_type = 'Group' AND project_collections.collectable_id = %i AND (projects.private = 'f' OR projects.type = 'ExternalProject') AND date_part('days', now() - projects.made_public_at) < 31 AND date_part('days', now() - projects.made_public_at) > 1 GROUP BY date ORDER BY date;"

    @new_project_views_sql = "SELECT to_char(impressions.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM impressions INNER JOIN project_collections ON project_collections.project_id = impressions.impressionable_id WHERE impressions.impressionable_type = 'Project' AND project_collections.collectable_type = 'Group' AND project_collections.collectable_id = %i AND date_part('days', now() - impressions.created_at) < 32 GROUP BY date ORDER BY date;"

    @new_views_sql = "SELECT to_char(impressions.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM impressions WHERE impressions.impressionable_type = 'Group' AND impressions.impressionable_id = %i AND date_part('days', now() - impressions.created_at) < 32  GROUP BY date ORDER BY date;"


    @new_respects_sql = "SELECT to_char(respects.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM respects INNER JOIN project_collections ON project_collections.project_id = respects.respectable_id AND respects.respectable_type = 'Project' WHERE project_collections.collectable_type = 'Group' AND project_collections.collectable_id = %i AND date_part('days', now() - respects.created_at) < 32 GROUP BY date ORDER BY date;"


    @new_follows_sql = "SELECT to_char(follow_relations.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM follow_relations WHERE date_part('days', now() - follow_relations.created_at) < 32 AND follow_relations.followable_type = 'Group' AND follow_relations.followable_id = %i GROUP BY date ORDER BY date;"
  end

  def load_projects options={}
    per_page = begin; [Integer(params[:per_page]), Project.per_page].min; rescue; Project.per_page end;  # catches both no and invalid params

    return unless platform = options[:platform] || @platform
    options[:type] ||= %w(Project ExternalProject)
    per_page = per_page - 1 if !options[:disable_ideas] and platform.accept_project_ideas and !options[:type] == 'Product'

    sort = if params[:sort] and params[:sort].in? Project::SORTING.keys
      params[:sort]
    else
      params[:sort] = platform.project_sorting.presence || 'trending'
    end
    @by = params[:by] || 'all'

    @projects = platform.project_collections.includes(:project).visible.order('project_collections.workflow_state DESC').merge(Project.for_thumb_display_in_collection)
    @projects = if sort == 'recent'
      @projects.most_recent
    else
      @projects.merge(Project.send(Project::SORTING[sort]))
    end

    if options[:type]
      @projects = @projects.joins(:project).merge(Project.where(type: options[:type]))  # fails without joins
    end

    if params[:tag]
      @projects = @projects.joins(:project).joins(project: :product_tags).where("LOWER(tags.name) = ?", CGI::unescape(params[:tag]))
    end

    if @by and @by.in? Project::FILTERS.keys
      @projects = if @by == 'featured'
        @projects.featured
      else
        @projects.merge(Project.send(Project::FILTERS[@by]))
      end
    end

    @projects = @projects.paginate(page: safe_page_params, per_page: per_page)
  end
end