class ProjectsController < ApplicationController
  before_filter :load_project_with_hid, only: [:show, :embed, :print, :update, :destroy]
  before_filter :load_project, only: [:redirect_to_slug_route]
  before_filter :ensure_belongs_to_platform, only: [:show, :embed, :print, :update, :destroy, :redirect_to_slug_route]
  before_filter :load_and_authorize_resource, only: [:edit, :submit, :update_workflow]
  respond_to :html
  after_action :allow_iframe, only: :embed
  skip_before_filter :track_visitor, only: [:show, :embed]
  skip_after_filter :track_landing_page, only: [:show, :embed]

  def index
    title "Explore all projects - Page #{safe_page_params || 1}"

    params[:sort] = (params[:sort].in?(BaseArticle::SORTING.keys) ? params[:sort] : 'trending')
    @by = (params[:by].in?(BaseArticle::FILTERS.keys) ? params[:by] : 'all')

    @projects = BaseArticle.indexable.for_thumb_display
    if params[:sort]
      @projects = @projects.send(BaseArticle::SORTING[params[:sort]])
    end

    if @by and @by.in? BaseArticle::FILTERS.keys
      @projects = @projects.send(BaseArticle::FILTERS[@by])
    end

    if params[:difficulty].try(:to_sym).in? BaseArticle::DIFFICULTIES.values
      @projects = @projects.where(difficulty: params[:difficulty])
    end

    if params[:type].try(:to_sym).in? BaseArticle.content_types(%w(Project Article)).values
      @projects = @projects.with_type(params[:type])
    end

    @projects = @projects.paginate(page: safe_page_params)

    respond_to do |format|
      format.html
      format.atom { render layout: false }
      format.rss { redirect_to projects_path(params.merge(format: :atom)), status: :moved_permanently }
    end
  end

  def show
    authorize! :read, @project unless params[:auth_token] and params[:auth_token] == @project.security_token

    if user_signed_in?
      impressionist_async @project, '', unique: [:session_hash]
    else
      surrogate_keys = [@project.record_key, 'project']
      surrogate_keys << current_platform.user_name if is_whitelabel?
      set_surrogate_key_header *surrogate_keys
      set_cache_control_headers
    end

    @can_edit = (user_signed_in? and current_user.can? :edit, @project)

    @challenge_entries = @project.challenge_entries.where(workflow_state: ChallengeEntry::APPROVED_STATES).includes(:challenge).includes(:prizes)
    @communities = @project.groups.where.not(groups: { type: 'Event' }).includes(:avatar).order(full_name: :asc)

    @hardware_parts = @project.part_joins.hardware.includes(part: :image)
    @software_parts = @project.part_joins.software.includes(part: :image)
    @tool_parts = @project.part_joins.tool.includes(part: :image)

    title @project.name
    @project_meta_desc = "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on Hackster.io."
    meta_desc @project_meta_desc
    @project = @project.decorate

    @other_projects = SimilarProjectsFinder.new(@project).results.for_thumb_display
    @other_projects = @other_projects.with_group current_platform if is_whitelabel?

    @team_members = @project.team_members.includes(:user).includes(user: :avatar)

    if @project.public?
      @respecting_users = @project.respecting_users.includes(:avatar).where.not(users: { full_name: nil }).limit(8)
      @replicating_users = @project.replicated_users.includes(:avatar).where.not(users: { full_name: nil }).limit(8)
      if is_whitelabel?
        @respecting_users = @respecting_users.where(users: { enable_sharing: true })
        @replicating_users = @replicating_users.where(users: { enable_sharing: true })
      end
    end

    @comments = @project.comments.includes(:parent, user: :avatar)
    if is_whitelabel?
      @comments = @comments.joins(:user).where(users: { enable_sharing: true })
    end

    if @project.has_assignment?
      @issue = Feedback.where(threadable_type: 'BaseArticle', threadable_id: @project.id).first
      @issue_comments = @issue.comments.includes(:user).includes(:parent) if @issue #.includes(user: :avatar)
    end

    # track_event 'Viewed project', @project.to_tracker.merge({ own: !!current_user.try(:is_team_member?, @project) })
  end

  def print
    authorize! :read, @project unless params[:auth_token] and params[:auth_token] == @project.security_token
    @project = @project.decorate
    render layout: 'print'
  end

  def claim
    @project = BaseArticle.find_by_id!(params[:id]).decorate
    authorize! :claim, @project

    @project.build_team unless @project.team
    if @project.external
      @project.team.members.new(user_id: current_user.id)
    else
      m = @project.team.members.new(user_id: current_user.id)
      m.permission_action = 'read'
      m.save
    end
    # @project.guest_name = nil
    @project.mark_needs_review! if @project.can_mark_needs_review?
    # @project.save

    redirect_to project_path(@project), notice: "You just claimed #{@project.name}. We'll let you know when it's approved!"
  end

  def embed
    surrogate_keys = [@project.record_key, "projects/#{@project.id}/embed"]
    surrogate_keys << current_platform.user_name if is_whitelabel?
    set_surrogate_key_header *surrogate_keys
    set_cache_control_headers

    title @project.name
    meta_desc "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on #{site_name}."
    @project = @project.decorate
    render layout: 'embed'

    # track_event 'Rendered embed thumbnail', @project.to_tracker.merge({ referrer: request.referrer })
  end

  def new
    model_class = if params[:type] and params[:type].in? BaseArticle::MACHINE_TYPES.keys
      BaseArticle::MACHINE_TYPES[params[:type]].constantize
    else
      Project
    end
    @project = model_class.new params[:base_article]
    authorize! :create, @project

    initialize_project
    event = if @project.external?
      'Attempted to submit a link'
    else
      'Attempted to create a project'
    end

    track_event event
  end

  def create
    model_class = if params[:base_article] and params[:base_article][:type] and params[:base_article][:type].in? BaseArticle::MACHINE_TYPES.values
      params[:base_article][:type].constantize
    else
      Project
    end
    @project = model_class.new params[:base_article]
    authorize! :create, @project

    if @project.external? or @project.product?
      event = 'Submitted link'
    else
      # @project.approve!
      @project.private = true
      event = 'Created project'
    end

    if @project.external?
      @project.content_type = :external
    end

    if current_platform
      @project.platform_tags_string = current_platform.name
    end

    if current_user
      @project.build_team
      @project.team.members.new(user_id: current_user.id)
    end

    if @project.save
      flash[:notice] = "#{@project.name} was successfully created."
      if @project.external? or @project.product?
        redirect_to user_return_to, notice: "Thanks for your submission!"
      else
        respond_with @project, location: edit_project_path(@project)
      end

      track_event event, @project.to_tracker
    else
      initialize_project
      render action: "new"
    end
  end

  def edit
    redirect_to @project, alert: "Your project is locked and cannot be edited at this time." if @project.locked? and !current_user.try(:is?, :admin)

    title 'Edit project'
    initialize_project
    @team = @project.team
    @show_admin_bar = true if params[:show_admin_bar] and current_user.is? :admin, :moderator
  end

  def update
    authorize! :update, @project
    private_was = @project.private

    if @project.update_attributes(params[:base_article])
      notice = "#{@project.name} was successfully updated."
      if private_was != @project.private
        if @project.private == false
          notice = nil# "#{@project.name} is now published. Somebody from the Hackster team still needs to approve it before it shows on the site. Sit tight!"
          session[:share_modal] = 'published_share_prompt'
          session[:share_modal_model] = 'project'
          session[:share_modal_model_id] = @project.id
          session[:share_modal_time] = 'after_redirect'

          track_event 'Made project public', @project.to_tracker
        elsif @project.private == false
          notice = "#{@project.name} is now private again."
        end
      end
      @project = @project.decorate
      respond_with @project do |format|
        format.html do
          flash[:notice] = notice
          redirect_to @project
        end
      end

      track_event 'Updated project', @project.to_tracker.merge({ type: 'project update'})
    else
      if params[:base_article].try(:[], 'private') == '0'
        flash[:alert] = "Couldn't publish the project, please email us at hi@hackster.io to get help."
      end
      redirect_to @project
    end
  end

  def update_workflow
    if @project.send "#{params[:event]}!", reviewer_id: current_user.id, review_comment: params[:comment]
      flash[:notice] = "Article state changed to: #{params[:event]}."
      redirect_to admin_projects_path(workflow_state: 'pending_review')
    else
      # flash[:error] = "Couldn't #{params[:event].gsub(/_/, ' ')} challenge, please try again or contact an admin."
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @project

    @project.destroy

    flash[:notice] = "Farewell #{@project.name}, we loved you."

    respond_with current_user
  end

  def redirect_to_slug_route
    if @project.public?
      redirect_to url_for(@project), status: 301
    else
      redirect_to polymorphic_path(@project, auth_token: params[:auth_token])
    end
  end

  def redirect_to_last
    project = BaseArticle.last
    url = case project
    when Product
      product_path(project)
    when ExternalProject
      project_path(project)
    else
      url_for(project)
    end
    redirect_to url, status: 302
  end

  def submit
    authorize! :edit, @project
    msg = 'Your assignment has been submitted. '
    @project.assignment_submitted_at = Time.now
    if @project.assignment.past_due? or !(deadline = @project.assignment.submit_by_date)
      @project.locked = true
      msg += 'The project will be locked for modifications until grades are sent out.'
    else
      msg += "You can still make modifications to the project until the submission deadline on #{l deadline.in_time_zone(PDT_TIME_ZONE)} PT."
    end
    @project.save
    redirect_to @project, notice: msg
  end

  private
    def ensure_belongs_to_platform
      if is_whitelabel?
        if !ProjectCollection.exists?(@project.id, 'Group', current_platform.id) or @project.users.reject{|u| u.enable_sharing }.any?
          raise ActiveRecord::RecordNotFound
        end
      end
    end

    def initialize_project
      @project.build_cover_image unless @project.cover_image
    end

    def load_and_authorize_resource
      @project = BaseArticle.find params[:id]
      authorize! self.action_name, @project
    end
end