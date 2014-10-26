class TechesController < ApplicationController
  include FilterHelper
  include GraphHelper

  before_filter :authenticate_user!, except: [:show, :embed, :index]
  before_filter :load_tech, except: [:show, :embed, :index, :analytics]
  before_filter :load_tech_with_slug, only: [:show, :embed, :analytics]
  before_filter :load_projects, only: [:show, :embed]
  before_filter :load_project, only: [:feature_project, :unfeature_project]
  layout 'tech', only: [:edit, :update, :show, :analytics]
  after_action :allow_iframe, only: [:embed]
  respond_to :html

  def index
    title "Explore tools"
    meta_desc "Find hardware and software tools to help you build your next hacks."
    @teches = Tech.public.for_thumb_display.order(:full_name)

    render "groups/teches/#{self.action_name}"
  end

  def show
    impressionist_async @tech, "", unique: [:session_hash]
    # authorize! :read, @tech
    title "#{@tech.name} hacks and projects"
    meta_desc "Discover hacks and projects built with #{@tech.name}, and share your own!"

    @announcement = @tech.announcements.current
    @challenge = @tech.active_challenge ? @tech.challenges.active.first : nil

    render "groups/teches/#{self.action_name}"

    track_event 'Visited tech', @tech.to_tracker.merge({ page: safe_page_params })
  end

  def embed
    title "Projects built with #{@tech.name}"
    @list_style = ([params[:list_style]] & ['', '_horizontal']).first || ''
    @list_style = '_vertical' if @list_style == ''
    render "groups/teches/#{self.action_name}", layout: 'embed'
  end

  def analytics
    authorize! :admin, @tech
    title "#{@tech.name} projects - Analytics dashboard"

    @project_count = @tech.projects_count
    @external_project_count = @tech.projects.visible.external.approved.count
    @comment_count = @tech.projects.joins(:comments).count
    @like_count = @tech.projects.joins(:respects).count
    @follow_count = @tech.followers_count
    @views_count = @tech.impressions.count
    @project_views_count = @tech.projects.joins(:impressions).count
    @new_projects_count = @tech.projects.visible.indexable_and_external.where('projects.made_public_at > ?', Date.today).count
    @new_comments_count = @tech.projects.joins(:comments).where('comments.created_at > ?', Date.today).count
    @new_likes_count = @tech.projects.joins(:respects).where('respects.created_at > ?', Date.today).count
    @new_follows_count = @tech.followers.where('follow_relations.created_at > ?', Date.today).count
    @new_views_count = @tech.impressions.where('impressions.created_at > ?', Date.today).count
    @new_project_views_count = @tech.projects.joins(:impressions).where('impressions.created_at > ?', Date.today).count

    sql = "SELECT users.*, t1.count FROM (SELECT members.user_id as user_id, COUNT(*) as count FROM members INNER JOIN groups AS team ON team.id = members.group_id INNER JOIN projects ON projects.team_id = team.id INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? AND projects.private = 'f' AND projects.hide = 'f' AND projects.approved = 't' AND (projects.guest_name = '' OR projects.guest_name IS NULL) GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 1 ORDER BY t1.count DESC LIMIT 10;"
    @heroes = User.find_by_sql([sql, @tech.id])

    sql = "SELECT users.*, t1.count FROM (SELECT respects.respecting_id as user_id, COUNT(*) as count FROM respects INNER JOIN projects ON projects.id = respects.project_id INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE project_collections.collectable_type = 'Group' AND projects.private = 'f' AND projects.hide = 'f' AND projects.approved = 't' AND (projects.guest_name = '' OR projects.guest_name IS NULL) AND project_collections.collectable_id = ? GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 1 AND (NOT (users.roles_mask & ? > 0) OR users.roles_mask IS NULL) ORDER BY t1.count DESC LIMIT 10;"
    @fans = User.find_by_sql([sql, @tech.id, 2**User::ROLES.index('admin')])

    sql = "SELECT projects.*, t1.count FROM (SELECT respects.project_id as project_id, COUNT(*) as count FROM respects INNER JOIN project_collections ON project_collections.project_id = respects.project_id WHERE project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? GROUP BY respects.project_id) AS t1 INNER JOIN projects ON projects.id = t1.project_id WHERE t1.count > 1 AND projects.private = 'f' AND projects.approved = 't' ORDER BY t1.count DESC LIMIT 10;"
    @most_respected_projects = Project.find_by_sql([sql, @tech.id])

    sql = "SELECT projects.*, t1.count FROM (SELECT impressions.impressionable_id as project_id, COUNT(*) as count FROM impressions INNER JOIN project_collections ON project_collections.project_id = impressions.impressionable_id WHERE project_collections.collectable_type = 'Group' AND impressions.impressionable_type = 'Project' AND project_collections.collectable_id = ? GROUP BY impressions.impressionable_id) AS t1 INNER JOIN projects ON projects.id = t1.project_id WHERE t1.count > 1 AND projects.private = 'f' AND projects.approved = 't' ORDER BY t1.count DESC LIMIT 10;"
    @most_viewed_projects = Project.find_by_sql([sql, @tech.id])

    @most_recent_projects = @tech.projects.visible.indexable_and_external.joins(:users).order(made_public_at: :desc).distinct("projects.id").limit(3)

    sql = "SELECT comments.* FROM comments INNER JOIN projects ON comments.commentable_id = projects.id INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE comments.commentable_type = 'Project' AND project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? ORDER BY comments.created_at DESC LIMIT 3"
    @most_recent_comments = Comment.find_by_sql [sql, @tech.id]

    @most_recent_followers = @tech.follow_relations.order(created_at: :desc).limit(10)

    sql = "SELECT to_char(projects.made_public_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM projects INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE project_collections.collectable_type = 'Group' AND project_collections.collectable_id = %i AND projects.private = 'f' AND date_part('days', now() - projects.made_public_at) < 31 AND date_part('days', now() - projects.made_public_at) > 1 GROUP BY date ORDER BY date;"
    @new_projects = graph_with_dates_for sql % @tech.id, 'Projects in the last 30 days', 'AreaChart'

    sql = "SELECT to_char(impressions.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM impressions INNER JOIN project_collections ON project_collections.project_id = impressions.impressionable_id WHERE impressions.impressionable_type = 'Project' AND project_collections.collectable_type = 'Group' AND project_collections.collectable_id = %i AND date_part('days', now() - impressions.created_at) < 31 AND date_part('days', now() - impressions.created_at) > 1 GROUP BY date ORDER BY date;"
    @new_project_views = graph_with_dates_for sql % @tech.id, 'Project views in the last 30 days', 'AreaChart'

    sql = "SELECT to_char(impressions.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM impressions WHERE impressions.impressionable_type = 'Group' AND impressions.impressionable_id = %i AND date_part('days', now() - impressions.created_at) < 31 AND date_part('days', now() - impressions.created_at) > 1 GROUP BY date ORDER BY date;"
    @new_views = graph_with_dates_for sql % @tech.id, 'Page views in the last 30 days', 'AreaChart'


    sql = "SELECT to_char(respects.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM respects INNER JOIN project_collections ON project_collections.project_id = respects.project_id WHERE project_collections.collectable_type = 'Group' AND project_collections.collectable_id = %i AND date_part('days', now() - respects.created_at) < 31 AND date_part('days', now() - respects.created_at) > 1 GROUP BY date ORDER BY date;"
    @new_respects = graph_with_dates_for sql % @tech.id, 'Respects in the last 30 days', 'AreaChart'


    sql = "SELECT to_char(follow_relations.created_at, 'yyyy-mm-dd') as date, COUNT(*) as count FROM follow_relations WHERE date_part('days', now() - follow_relations.created_at) < 31 AND date_part('days', now() - follow_relations.created_at) > 1 AND follow_relations.followable_type = 'Group' AND follow_relations.followable_id = %i GROUP BY date ORDER BY date;"
    @new_follows = graph_with_dates_for sql % @tech.id, 'Follows in the last 30 days', 'AreaChart'

    render "groups/teches/#{self.action_name}"
  end

  def edit
    authorize! :update, @tech
    @tech.build_avatar unless @tech.avatar

    render "groups/teches/#{self.action_name}"
  end

  def update
    authorize! :update, @tech
    old_tech = @tech.dup

    if @tech.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @tech, notice: 'Profile updated.' }
        format.js do
          # if old_group.interest_tags_string != @tech.interest_tags_string or old_group.skill_tags_string != @tech.skill_tags_string
          if old_tech.user_name != @tech.user_name
            @refresh = true
          end
          @tech = GroupDecorator.decorate(@tech)

          render "groups/teches/#{self.action_name}"
        end

        track_event 'Updated tech'
      end
    else
      @tech.build_avatar unless @tech.avatar
      respond_to do |format|
        format.html { render template: 'groups/teches/edit' }
        format.js { render json: { group: @tech.errors }, status: :unprocessable_entity }
      end
    end
  end

  def feature_project
    @group_rel = ProjectCollection.where(project_id: params[:project_id], collectable_id: params[:tech_id], collectable_type: 'Group').first!

    if @group_rel.feature!
      respond_to do |format|
        format.html { redirect_to @project, notice: "#{@project.name} has been featured." }
        format.js { render 'groups/teches/button_featured' }
      end
      event_name = 'Respected project'
    else
      respond_to do |format|
        format.html { redirect_to @project, alert: "Couldn\'t feature project!" }
        format.js { render text: 'alert("Couldn\'t feature project!")' }
      end
      event_name = 'Tried respecting own project'
    end
  end

  def unfeature_project
    @group_rel = ProjectCollection.where(project_id: params[:project_id], collectable_id: params[:tech_id], collectable_type: 'Group').first!

    if @group_rel.unfeature!
      respond_to do |format|
        format.html { redirect_to @project, notice: "#{@project.name} was unfeatured." }
        format.js { render 'groups/teches/button_featured' }
      end
    end
  end

  private
    def load_projects
      per_page = params[:per_page] ? [Integer(params[:per_page]), Project.per_page].min : Project.per_page
      per_page = per_page - 1 if @tech.accept_project_ideas
      @projects = @tech.projects.visible.indexable_and_external.order('project_collections.workflow_state DESC').magic_sort.for_thumb_display.paginate(page: safe_page_params, per_page: per_page)
    end

    def load_tech
      @tech = Tech.find(params[:tech_id] || params[:id])
    end

    def load_tech_with_slug
      @tech = load_with_slug
    end
end