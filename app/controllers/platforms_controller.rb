class PlatformsController < ApplicationController
  include FilterHelper
  include GraphHelper

  before_filter :authenticate_user!, except: [:show, :embed, :index]
  before_filter :load_platform, except: [:show, :embed, :index, :analytics]
  before_filter :load_platform_with_slug, only: [:show, :embed, :analytics]
  before_filter :load_projects, only: [:embed]
  before_filter :load_project, only: [:feature_project, :unfeature_project]
  layout 'group_shared', only: [:edit, :update, :show, :analytics]
  after_action :allow_iframe, only: [:embed]
  respond_to :html
  protect_from_forgery except: :embed

  def index
    title "Explore platforms"
    meta_desc "Find hardware and software platforms to help you build your next projects."

    params[:sort] = (params[:sort].in?(Group::SORTING.keys) ? params[:sort] : 'followers')

    @platforms = Platform.public.for_thumb_display
    if params[:sort]
      @platforms = @platforms.send(Group::SORTING[params[:sort]])
    end

    if params[:tag]
      @platforms = @platforms.joins(:product_tags).where("LOWER(tags.name) = ?", params[:tag].downcase)
    end

    render "groups/platforms/#{self.action_name}"
  end

  def show
    authorize! :read, @platform
    impressionist_async @platform, "", unique: [:session_hash]

    title "#{@platform.name} projects"
    meta_desc "Explore #{@platform.projects_count} projects built with #{@platform.name}, and share your own! Join #{@platform.followers_count} hackers who follow #{@platform.name} on Hackster."

    @announcement = @platform.announcements.current
    @challenge = @platform.active_challenge ? @platform.challenges.active.first : nil

    # track_event 'Visited platform', @platform.to_tracker.merge({ page: safe_page_params })
    respond_to do |format|
      format.html do
        load_projects
        render "groups/shared/show"
      end
      format.atom do
        load_projects_for_rss
        render template: "projects/index", layout: false
      end
      format.rss { redirect_to platform_short_path(@platform, params.merge(format: :atom)), status: :moved_permanently }
    end
  end

  def embed
    title "Projects built with #{@platform.name}"
    @list_style = ([params[:list_style]] & ['', '_horizontal']).first || ''
    @list_style = '_vertical' if @list_style == ''
    respond_to do |format|
      format.html { render "groups/platforms/embed", layout: 'embed' }
      format.js do
        @projects = @projects.map do |project|
          project.project.to_js
        end.to_json
        render "groups/platforms/embed"
      end
    end
  end

  def analytics
    authorize! :admin, @platform
    title "#{@platform.name} projects - Analytics dashboard"

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

    sql = "SELECT users.*, t1.count FROM (SELECT members.user_id as user_id, COUNT(*) as count FROM members INNER JOIN groups AS team ON team.id = members.group_id INNER JOIN projects ON projects.team_id = team.id INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? AND projects.private = 'f' AND projects.hide = 'f' AND projects.approved = 't' AND (projects.guest_name = '' OR projects.guest_name IS NULL) GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 1 ORDER BY t1.count DESC LIMIT 10;"
    @heroes = User.find_by_sql([sql, @platform.id])

    sql = "SELECT users.*, t1.count FROM (SELECT respects.respecting_id as user_id, COUNT(*) as count FROM respects INNER JOIN projects ON projects.id = respects.project_id INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE project_collections.collectable_type = 'Group' AND projects.private = 'f' AND projects.hide = 'f' AND projects.approved = 't' AND (projects.guest_name = '' OR projects.guest_name IS NULL) AND project_collections.collectable_id = ? GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 1 AND (NOT (users.roles_mask & ? > 0) OR users.roles_mask IS NULL) ORDER BY t1.count DESC LIMIT 10;"
    @fans = User.find_by_sql([sql, @platform.id, 2**User::ROLES.index('admin')])

    sql = "SELECT projects.*, t1.count FROM (SELECT respects.project_id as project_id, COUNT(*) as count FROM respects INNER JOIN project_collections ON project_collections.project_id = respects.project_id WHERE project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? GROUP BY respects.project_id) AS t1 INNER JOIN projects ON projects.id = t1.project_id WHERE t1.count > 1 AND projects.private = 'f' AND projects.approved = 't' ORDER BY t1.count DESC LIMIT 10;"
    @most_respected_projects = Project.find_by_sql([sql, @platform.id])

    sql = "SELECT projects.*, t1.count FROM (SELECT impressions.impressionable_id as project_id, COUNT(*) as count FROM impressions INNER JOIN project_collections ON project_collections.project_id = impressions.impressionable_id WHERE project_collections.collectable_type = 'Group' AND impressions.impressionable_type = 'Project' AND project_collections.collectable_id = ? GROUP BY impressions.impressionable_id) AS t1 INNER JOIN projects ON projects.id = t1.project_id WHERE t1.count > 1 AND projects.private = 'f' AND projects.approved = 't' ORDER BY t1.count DESC LIMIT 10;"
    @most_viewed_projects = Project.find_by_sql([sql, @platform.id])

    @most_recent_projects = @platform.projects.visible.indexable_and_external.joins(:users).order(made_public_at: :desc).distinct("projects.id").limit(3)

    sql = "SELECT comments.* FROM comments INNER JOIN projects ON comments.commentable_id = projects.id INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE comments.commentable_type = 'Project' AND project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? ORDER BY comments.created_at DESC LIMIT 3"
    @most_recent_comments = Comment.find_by_sql [sql, @platform.id]

    @most_recent_followers = @platform.follow_relations.order(created_at: :desc).limit(10)

    sql = "SELECT to_char(projects.made_public_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM projects INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE project_collections.collectable_type = 'Group' AND project_collections.collectable_id = %i AND (projects.private = 'f' OR projects.external = 't') AND date_part('days', now() - projects.made_public_at) < 31 AND date_part('days', now() - projects.made_public_at) > 1 GROUP BY date ORDER BY date;"
    @new_projects = graph_with_dates_for sql % @platform.id, 'Projects in the last 30 days', 'AreaChart', Project.indexable_and_external.joins(:project_collections).where(project_collections: { collectable_id: @platform.id, collectable_type: 'Group' }).where('projects.created_at < ?', 32.days.ago).count

    sql = "SELECT to_char(impressions.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM impressions INNER JOIN project_collections ON project_collections.project_id = impressions.impressionable_id WHERE impressions.impressionable_type = 'Project' AND project_collections.collectable_type = 'Group' AND project_collections.collectable_id = %i AND date_part('days', now() - impressions.created_at) < 32 GROUP BY date ORDER BY date;"
    @new_project_views = graph_with_dates_for sql % @platform.id, 'Project views in the last 30 days', 'AreaChart'

    sql = "SELECT to_char(impressions.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM impressions WHERE impressions.impressionable_type = 'Group' AND impressions.impressionable_id = %i AND date_part('days', now() - impressions.created_at) < 32  GROUP BY date ORDER BY date;"
    @new_views = graph_with_dates_for sql % @platform.id, 'Page views in the last 30 days', 'AreaChart'


    sql = "SELECT to_char(respects.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM respects INNER JOIN project_collections ON project_collections.project_id = respects.project_id WHERE project_collections.collectable_type = 'Group' AND project_collections.collectable_id = %i AND date_part('days', now() - respects.created_at) < 32 GROUP BY date ORDER BY date;"
    @new_respects = graph_with_dates_for sql % @platform.id, 'Respects in the last 30 days', 'AreaChart', Respect.joins('INNER JOIN project_collections ON project_collections.project_id = respects.project_id').where(project_collections: { collectable_type: 'Group', collectable_id: @platform.id }).where('respects.created_at < ?', 32.days.ago).count


    sql = "SELECT to_char(follow_relations.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM follow_relations WHERE date_part('days', now() - follow_relations.created_at) < 32 AND follow_relations.followable_type = 'Group' AND follow_relations.followable_id = %i GROUP BY date ORDER BY date;"
    @new_follows = graph_with_dates_for sql % @platform.id, 'Follows in the last 30 days', 'AreaChart', FollowRelation.where(followable_type: 'Group', followable_id: @platform.id).where('follow_relations.created_at < ?', 32.days.ago).count

    render "groups/platforms/#{self.action_name}"
  end

  def update
    authorize! :update, @platform
    old_platform = @platform.dup

    if @platform.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @platform, notice: 'Profile updated.' }
        format.js do
          # if old_group.interest_tags_string != @platform.interest_tags_string or old_group.skill_tags_string != @platform.skill_tags_string
          if old_platform.user_name != @platform.user_name
            @refresh = true
          end
          @platform = GroupDecorator.decorate(@platform)

          render "groups/platforms/#{self.action_name}"
        end

        track_event 'Updated platform'
      end
    else
      @platform.build_avatar unless @platform.avatar
      respond_to do |format|
        format.html { render template: 'groups/platforms/edit' }
        format.js { render json: { group: @platform.errors }, status: :unprocessable_entity }
      end
    end
  end

  def feature_project
    @group_rel = ProjectCollection.where(project_id: params[:project_id], collectable_id: params[:platform_id], collectable_type: 'Group').first!

    if (@group_rel.can_feature? and @group_rel.feature!) or @group_rel.featured?
      respond_to do |format|
        format.html { redirect_to @project, notice: "#{@project.name} has been featured." }
        format.js { render 'groups/platforms/button_featured' }
      end
    else
      respond_to do |format|
        format.html { redirect_to @project, notice: "Couldn\'t feature project!" }
        format.js { render text: 'alert("Couldn\'t feature project!")' }
      end
    end
  end

  def unfeature_project
    @group_rel = ProjectCollection.where(project_id: params[:project_id], collectable_id: params[:platform_id], collectable_type: 'Group').first!

    if (@group_rel.can_unfeature? and @group_rel.unfeature!) or @group_rel.approved?
      respond_to do |format|
        format.html { redirect_to @project, notice: "#{@project.name} was unfeatured." }
        format.js { render 'groups/platforms/button_featured' }
      end
    end
  end

  private
    def load_projects
      per_page = begin; [Integer(params[:per_page]), Project.per_page].min; rescue; Project.per_page end;  # catches both no and invalid params

      per_page = per_page - 1 if @platform.accept_project_ideas

      sort = if params[:sort] and params[:sort].in? Project::SORTING.keys
        params[:sort]
      else
        params[:sort] = @platform.project_sorting.presence || 'magic'
      end
      @by = params[:by] || 'all'

      @projects = @platform.project_collections.includes(:project).visible.order('project_collections.workflow_state DESC').merge(Project.for_thumb_display_in_collection)
      @projects = @projects.merge(Project.send(Project::SORTING[sort]))

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

      # @projects = Project.joins(:visible_platforms).where("groups.id = ?", @platform.id).order('project_collections.workflow_state DESC').for_thumb_display
      # @projects = @projects.send(Project::SORTING[sort])

      # if @by and @by.in? Project::FILTERS.keys
      #   @projects = if @by == 'featured'
      #     @projects.featured
      #   else
      #     @projects.send(Project::FILTERS[@by])
      #   end
      # end

      @projects = @projects.paginate(page: safe_page_params, per_page: per_page)

    end

    def load_projects_for_rss
      per_page = begin; [Integer(params[:per_page]), Project.per_page].min; rescue; Project.per_page end;  # catches both no and invalid params

      per_page = per_page - 1 if @platform.accept_project_ideas

      sort = if params[:sort] and params[:sort].in? Project::SORTING.keys
        params[:sort]
      else
        params[:sort] = 'recent'
      end
      @by = params[:by] || 'all'

      @projects = Project.joins(:visible_platforms).where("groups.id = ?", @platform.id).for_thumb_display
      @projects = @projects.send(Project::SORTING[sort])

      if @by and @by.in? Project::FILTERS.keys
        @projects = if @by == 'featured'
          @projects.featured
        else
          @projects.send(Project::FILTERS[@by])
        end
      end

      @projects = @projects.paginate(page: safe_page_params, per_page: per_page)

    end

    def load_platform
      @group = @platform = Platform.find(params[:platform_id] || params[:id])
    end

    def load_platform_with_slug
      @group = @platform = load_with_slug#.try(:decorate)
    end
end