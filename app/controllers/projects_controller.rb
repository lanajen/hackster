class ProjectsController < ApplicationController
  before_filter :load_project, only: [:show, :embed, :print, :update, :destroy, :redirect_to_slug_route]
  before_filter :ensure_belongs_to_platform, only: [:show, :embed, :print, :update, :destroy, :redirect_to_slug_route]
  load_and_authorize_resource only: [:index, :new, :edit, :submit]
  # layout 'project', only: [:edit, :update, :show]
  before_filter :load_lists, only: [:show, :show_external]
  respond_to :html
  after_action :allow_iframe, only: :embed

  def index
    title "Explore all projects - Page #{safe_page_params || 1}"

    params[:sort] = (params[:sort].in?(Project::SORTING.keys) ? params[:sort] : 'trending')
    @by = (params[:by].in?(Project::FILTERS.keys) ? params[:by] : 'all')

    @projects = Project.indexable.for_thumb_display
    if params[:sort]
      @projects = @projects.send(Project::SORTING[params[:sort]])
    end

    if @by and @by.in? Project::FILTERS.keys
      @projects = @projects.send(Project::FILTERS[@by])
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

    impressionist_async @project, '', unique: [:session_hash]

    @show_part_of = ProjectCollection.assignment_or_event_for_project? @project.id
    @show_sidebar = true
    @can_edit = (user_signed_in? and current_user.can? :edit, @project)
    @can_update = (@can_edit and current_user.can? :update, @project)

    @collections = @project.project_collections.includes(:collection)
    @challenge_entries = @project.challenge_entries.includes(:challenge).includes(:prize)
    @winning_entry = @challenge_entries.select{|e| e.awarded? }.first

    title @project.name
    @project_meta_desc = "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on Hackster.io."
    meta_desc @project_meta_desc
    @project = @project.decorate
    # @widgets_by_section ={ 1=>[], 2=>[], 3=>[], 4=>[] }
    @widgets = @project.widgets.order(:created_at)#.each{|w| @widgets_by_section[w.position[0].to_i] << w }

    # other projects by same author
    @other_projects_count = Project.public.most_popular.includes(:team_members).references(:members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: @project.id)
    @other_projects_count = @other_projects_count.with_group current_platform if is_whitelabel?
    @other_projects_count = @other_projects_count.size

    if @other_projects_count > 6
      @other_projects = Project.public.most_popular.own.includes(:team_members).references(:members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: @project.id).includes(:team).includes(:cover_image)
      @other_projects.with_group current_platform if is_whitelabel?
      @other_projects = @other_projects.limit(3)

      @last_projects = Project.public.last_public.own.includes(:team_members).references(:members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: [@project.id] + @other_projects.map(&:id)).includes(:team).includes(:cover_image)
      @last_projects = @last_projects.with_group current_platform if is_whitelabel?
      @last_projects = @last_projects.limit(3)
    else
      @other_projects = Project.public.most_popular.own.includes(:team_members).references(:members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: @project.id).includes(:team).includes(:cover_image)
      @other_projects = @other_projects.with_group current_platform if is_whitelabel?
    end

    # next/previous project in search
    # if params[:ref] and params[:ref_id] and params[:offset]
    #   offset = params[:offset].to_i
    #   case params[:ref]
    #   when 'assignment'
    #     if @assignment = Assignment.find_by_id(params[:ref_id])
    #       @next = @assignment.projects.order(:created_at).offset(offset + 1).first
    #       @prev = @assignment.projects.order(:created_at).offset(offset - 1).first unless offset.zero?
    #     end
    #   when 'explore'
    #     sort, by = params[:ref_id].split(/_/)

    #     @projects = Project
    #     if sort.in? Project::SORTING.keys
    #       @projects = @projects.send(Project::SORTING[sort])
    #     end

    #     if by.in? Project::FILTERS.keys
    #       @projects = @projects.send(Project::FILTERS[by])
    #     end

    #     @next = @projects.indexable.offset(offset + 1).first
    #     @prev = @projects.indexable.offset(offset - 1).first unless offset.zero?

    #   when 'event'
    #     if @event = Event.find_by_id(params[:ref_id])
    #       @next = @event.projects.live.order('projects.respects_count DESC').offset(offset + 1).first
    #       @prev = @event.projects.live.order('projects.respects_count DESC').offset(offset - 1).first unless offset.zero?
    #     end

    #   when 'search'
    #     params[:q] = params[:ref_id]
    #     params[:type] = 'project'
    #     params[:per_page] = 1
    #     params[:offset] = offset + 1
    #     params[:include_external] = false
    #     @next = SearchRepository.new(params).search.results.first
    #     unless offset.zero?
    #       params[:offset] = offset - 1
    #       @prev = SearchRepository.new(params).search.results.first
    #     end
    #     params[:offset] = offset
    #     params.delete(:include_external)
    #   when 'user'
    #     if @user = User.find_by_id(params[:ref_id])
    #       @next = @user.projects.live.order(start_date: :desc, created_at: :desc).offset(offset + 1).first
    #       @prev = @user.projects.live.order(start_date: :desc, created_at: :desc).offset(offset - 1).first unless offset.zero?
    #     end
    #   end
    # end

    @team_members = @project.team_members.includes(:user).includes(user: :avatar)

    if is_whitelabel?
      @comments = @project.comments.joins(:user).where(users: { enable_sharing: true }).includes(:user).includes(:parent).includes(user: :avatar)
      @respecting_users = @project.respecting_users.where(users: { enable_sharing: true }).includes(:avatar) if @project.public?
    else
      @comments = @project.comments.includes(:user).includes(:parent)#.includes(user: :avatar)
      @respecting_users = @project.respecting_users.includes(:avatar) if @project.public?
    end

    if @project.has_assignment?
      @issue = Feedback.where(threadable_type: 'Project', threadable_id: @project.id).first
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
    @project = Project.find_by_id!(params[:id]).decorate
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
    @project.approved = nil
    @project.save

    redirect_to project_path(@project), notice: "You just claimed #{@project.name}. We'll let you know when it's approved!"
  end

  def embed
    title @project.name
    meta_desc "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on #{site_name}."
    @project = @project.decorate
    render layout: 'embed'

    # track_event 'Rendered embed thumbnail', @project.to_tracker.merge({ referrer: request.referrer })
  end

  def new
    model_class = if params[:type] and params[:type].in? Project::MACHINE_TYPES.keys
      Project::MACHINE_TYPES[params[:type]].constantize
    else
      Project
    end
    @project = model_class.new params[:project]
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
    model_class = if params[:project] and params[:project][:type] and params[:project][:type].in? Project::MACHINE_TYPES.values
      params[:project][:type].constantize
    else
      Project
    end
    @project = model_class.new params[:project]
    authorize! :create, @project

    if @project.external? or @project.product?
      event = 'Submitted link'
    else
      # @project.approved = true
      @project.private = true
      event = 'Created project'
    end

    if current_platform
      @project.platform_tags_string = current_platform.name
    end

    if !@project.product? and current_user
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
    title 'Edit project'
    initialize_project
    @team = @project.team
    @project = @project.decorate
  end

  def update
    authorize! :update, @project
    private_was = @project.private

    if @project.update_attributes(params[:project])
      notice = "#{@project.name} was successfully updated."
      if private_was != @project.private
        if @project.private == false
          current_user.broadcast :new, @project.id, 'Project', @project.id
          notice = "#{@project.name} is now published. Somebody from the Hackster team still needs to approve it before it shows on the site. Sit tight!"
          session[:share_modal] = 'published_share_prompt'
          session[:share_modal_model] = 'project'

          track_event 'Made project public', @project.to_tracker
        elsif @project.private == false
          current_user.broadcast :update, @project.id, 'Project', @project.id
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
      if params[:project].try(:[], 'private') == '0'
        flash[:alert] = "Couldn't publish the project, please email us at hi@hackster.io to get help."
      end
      redirect_to @project
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
    project = Project.last
    url = case project
    when Product
      product_path(project)
    when ExternalProject
      external_project_path(project)
    else
      url_for(project)
    end
    redirect_to url, status: 302
  end

  def submit
    authorize! :edit, @project
    @project.assignment_submitted_at = Time.now
    @project.locked = true if @project.assignment.past_due?
    @project.save
    redirect_to @project, notice: 'Your assignment has been submitted. The project will be locked for modifications until grades are sent out.'
  end

  private
    def ensure_belongs_to_platform
      if is_whitelabel?
        if (current_platform.platform_tags.map{|t| t.name.downcase } & @project.platform_tags_cached.map{|t| t.downcase }).empty? or @project.users.reject{|u| u.enable_sharing }.any?
          raise ActiveRecord::RecordNotFound
        end
      end
    end

    def initialize_project
      @project.build_logo unless @project.logo
      @project.build_cover_image unless @project.cover_image
    end

    def load_lists
      @lists = if user_signed_in?
        if current_user.is? :admin
          List.where(type: 'List').order(:full_name)
        else
          current_user.lists.order(:full_name)
        end
      end
    end
end
