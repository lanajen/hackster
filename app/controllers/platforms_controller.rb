class PlatformsController < ApplicationController
  include FilterHelper
  include GraphHelper
  include PlatformHelper

  before_filter :authenticate_user!, except: [:show, :embed, :projects, :products, :followers, :index]
  before_filter :load_platform, except: [:show, :embed, :projects, :products, :followers, :index, :analytics]
  before_filter :load_platform_with_slug, only: [:show, :embed, :projects, :products, :followers, :analytics]
  before_filter :load_projects, only: [:embed]
  before_filter :load_project, only: [:feature_project, :unfeature_project]
  layout 'platform', only: [:edit, :update, :projects, :products, :followers, :analytics]
  after_action :allow_iframe, only: [:embed]
  respond_to :html
  protect_from_forgery except: :embed
  skip_before_filter :track_visitor, only: [:index, :show, :embed]
  skip_after_filter :track_landing_page, only: [:index, :show, :embed]

  def index
    unless user_signed_in?
      set_surrogate_key_header 'platforms'
      set_cache_control_headers 3600
    end

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

    if user_signed_in?
      impressionist_async @platform, "", unique: [:session_hash]
    else
      set_surrogate_key_header @platform.record_key, 'platform'
      set_cache_control_headers 3600
    end

    respond_to do |format|
      format.html do
        title "#{@platform.name}'s community hub"
        meta_desc "Explore #{@platform.name}'s community hub to learn and share about their products! Join #{@platform.followers_count} makers who follow #{@platform.name} on Hackster."

        sql = "SELECT users.*, t1.count FROM (SELECT members.user_id as user_id, COUNT(*) as count FROM members INNER JOIN groups AS team ON team.id = members.group_id INNER JOIN projects ON projects.team_id = team.id INNER JOIN project_collections ON project_collections.project_id = projects.id WHERE project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? AND projects.private = 'f' AND projects.hide = 'f' AND projects.workflow_state = 'approved' AND (projects.guest_name = '' OR projects.guest_name IS NULL) GROUP BY user_id) AS t1 INNER JOIN users ON users.id = t1.user_id WHERE t1.count > 0 ORDER BY t1.count DESC LIMIT 5;"
        @followers = User.find_by_sql([sql, @platform.id])
        if @followers.count < 5
          @followers = @platform.followers.top.limit(5)
        end
        @projects = @platform.project_collections.includes(:project).visible.order('project_collections.workflow_state DESC').merge(Project.for_thumb_display_in_collection).merge(Project.magic_sort).where(projects: { type: %w(Project ExternalProject) }).limit(3)
        @parts = @platform.parts.default_sort.limit(3) if @platform.enable_parts
        @products = @platform.project_collections.includes(:project).visible.order('project_collections.workflow_state DESC').merge(Project.for_thumb_display_in_collection).merge(Project.magic_sort).where(projects: { type: 'Product' }).limit(3) if @platform.enable_products
        @sub_parts = @platform.sub_parts.limit(3) if @platform.enable_sub_parts

        @announcement = @platform.announcements.current
        @challenge = @platform.active_challenge ? @platform.challenges.active.first : nil

        render "groups/platforms/show"
      end
      format.atom { redirect_to platform_projects_path(@platform, params.slice(:sort, :by).merge(format: :atom)), status: :moved_permanently }
      format.rss { redirect_to platform_projects_path(@platform, params.slice(:sort, :by).merge(format: :atom)), status: :moved_permanently }
    end
  end

  def projects
    authorize! :read, @platform
    impressionist_async @platform, "", unique: [:session_hash]

    title "#{@platform.name} projects"
    meta_desc "Explore #{@platform.projects_count} projects built with #{@platform.name}, and share your own! Join #{@platform.followers_count} makers who follow #{@platform.name} on Hackster."

    @announcement = @platform.announcements.current
    @challenge = @platform.active_challenge ? @platform.challenges.active.first : nil

    # track_event 'Visited platform', @platform.to_tracker.merge({ page: safe_page_params })
    respond_to do |format|
      format.html do
        load_projects
        render "groups/platforms/projects"
      end
      format.atom do
        load_projects_for_rss
        render template: "projects/index", layout: false
      end
      format.rss { redirect_to platform_projects_path(@platform, params.slice(:sort, :by).merge(format: :atom)), status: :moved_permanently }
    end
  end

  def products
    authorize! :read, @platform
    impressionist_async @platform, "", unique: [:session_hash]

    title "Devices made with #{@platform.name}"
    meta_desc "Explore #{@platform.products_count} devices built with #{@platform.name}! Join #{@platform.followers_count} makers who follow #{@platform.name} on Hackster."

    @announcement = @platform.announcements.current
    @challenge = @platform.active_challenge ? @platform.challenges.active.first : nil

    # track_event 'Visited platform', @platform.to_tracker.merge({ page: safe_page_params })
    respond_to do |format|
      format.html do
        load_projects type: 'Product'
        render "groups/platforms/products"
      end
      # format.atom do
      #   load_projects_for_rss
      #   render template: "projects/index", layout: false
      # end
      # format.rss { redirect_to platform_home_path(@platform, params.merge(format: :atom)), status: :moved_permanently }
    end
  end

  def embed
    set_surrogate_key_header "platforms/#{@platform.id}/embed"
    set_cache_control_headers 3600

    title "Projects built with #{@platform.name}"
    @list_style = ([params[:list_style]] & ['', '_horizontal']).first || ''
    @list_style = '_vertical' if @list_style == ''

    respond_to do |format|
      format.html { render "groups/platforms/embed", layout: 'embed' }
      format.js do
        @projects = @projects.map do |project|
          project.project.to_js
        end.to_json
        render "shared/embed"
      end
    end
  end

  def analytics
    authorize! :admin, @platform
    title "#{@platform.name} projects - Analytics dashboard"

    load_analytics

    @new_projects = graph_with_dates_for @new_projects_sql % @platform.id, 'Projects in the last 30 days', 'AreaChart', Project.indexable_and_external.joins(:project_collections).where(project_collections: { collectable_id: @platform.id, collectable_type: 'Group' }).where('projects.created_at < ?', 32.days.ago).count

    @new_project_views = graph_with_dates_for @new_project_views_sql % @platform.id, 'Project views in the last 30 days', 'AreaChart'

    @new_views = graph_with_dates_for @new_views_sql % @platform.id, 'Page views in the last 30 days', 'AreaChart'

    @new_respects = graph_with_dates_for @new_respects_sql % @platform.id, 'Respects in the last 30 days', 'AreaChart', Respect.joins("INNER JOIN project_collections ON project_collections.project_id = respects.respectable_id AND respects.respectable_type = 'Project'").where(project_collections: { collectable_type: 'Group', collectable_id: @platform.id }).where('respects.created_at < ?', 32.days.ago).count

    @new_follows = graph_with_dates_for @new_follows_sql % @platform.id, 'Follows in the last 30 days', 'AreaChart', FollowRelation.where(followable_type: 'Group', followable_id: @platform.id).where('follow_relations.created_at < ?', 32.days.ago).count

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

      @projects = @projects.merge(Project.where(type: %w(Project ExternalProject)))

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