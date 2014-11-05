class ProjectsController < ApplicationController
  before_filter :load_project, only: [:show, :embed, :update, :destroy, :redirect_to_slug_route]
  load_and_authorize_resource only: [:index, :edit, :settings, :submit]
  layout 'project', only: [:edit, :update, :show]
  before_filter :set_project_mode, only: [:settings]
  respond_to :html
  respond_to :js, only: [:edit, :update, :settings]
  after_action :allow_iframe, only: :embed

  def index
    title "Explore all projects - Page #{safe_page_params || 1}"

    params[:sort] ||= 'trending'
    @by = params[:by] || 'all'

    @projects = Project.indexable.for_thumb_display
    if params[:sort] and params[:sort].in? Project::SORTING.keys
      @projects = @projects.send(Project::SORTING[params[:sort]])
    end

    if params[:by] and params[:by].in? Project::FILTERS.keys
      @projects = @projects.send(Project::FILTERS[params[:by]])
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
    @other_projects_count = Project.public.most_popular.includes(:team_members).references(:members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: @project.id).size
    if @other_projects_count > 6
      @other_projects = Project.public.most_popular.includes(:team_members).references(:members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: @project.id).includes(:team).includes(:cover_image).limit(3)
      @last_projects = Project.public.last_public.includes(:team_members).references(:members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: [@project.id] + @other_projects.map(&:id)).includes(:team).includes(:cover_image).limit(3)
    else
      @other_projects = Project.public.most_popular.includes(:team_members).references(:members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: @project.id).includes(:team).includes(:cover_image)
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

    @comments = @project.comments.includes(:user).includes(:parent)#.includes(user: :avatar)

    if @project.has_assignment?
      @issue = Feedback.where(threadable_type: 'Project', threadable_id: @project.id).first
      @issue_comments = @issue.comments.includes(:user).includes(:parent) if @issue #.includes(user: :avatar)
    end

    @respecting_users = @project.respecting_users.includes(:avatar) if @project.public?

    # track_event 'Viewed project', @project.to_tracker.merge({ own: !!current_user.try(:is_team_member?, @project) })
  end

  def show_external
    @project = Project.external.find_by_id!(params[:id]).decorate
    impressionist_async @project, '', unique: [:session_hash]
    title @project.name
    meta_desc @project.one_liner
    # track_event 'Viewed project', @project.to_tracker.merge({ own: !!current_user.try(:is_team_member?, @project) })
  end

  def redirect_external
    @project = Project.external.find_by_slug!(params[:slug])
    redirect_to external_project_path(@project), status: 301
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
    meta_desc "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on Hackster.io."
    @project = @project.decorate
    render layout: 'embed'

    # track_event 'Rendered embed thumbnail', @project.to_tracker.merge({ referrer: request.referrer })
  end

  def new
    # somehow load_and_authorize_resource loads a model with external = true
    @project = Project.new params[:project]
    authorize! :create, @project

    initialize_project
    event = if @project.external
      'Attempted to submit a link'
    else
      'Attempted to create a project'
    end

    track_event event
  end

  def create
    # somehow load_and_authorize_resource loads a model with external = true
    @project = Project.new params[:project]
    authorize! :create, @project

    if @project.external
      event = 'Submitted link'
    else
      # @project.approved = true
      @project.private = true
      event = 'Created project'
    end

    if current_user
      @project.build_team
      @project.team.members.new(user_id: current_user.id)
    end

    if @project.save
      flash[:notice] = "#{@project.name} was successfully created."
      if @project.external
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
    @mode = 'edit_mode'
    @show_sidebar = true
    initialize_project
  end

  def settings
    authorize! :edit, @project
    title 'Project settings'
  end

  def update
    @mode = 'edit_mode'
    @show_sidebar = true
    authorize! :update, @project
    private_was = @project.private

    if @project.update_attributes(params[:project])
      if private_was != @project.private and @project.private == false
        current_user.broadcast :new, @project.id, 'Project', @project.id

        track_event 'Made project public', @project.to_tracker
      elsif @project.private == false
        current_user.broadcast :update, @project.id, 'Project', @project.id
      end
      @refresh = @project.slug_was_changed?
      @project = @project.decorate
      @widgets = @project.widgets.order(:created_at)
      notice = "#{@project.name} was successfully updated."
      respond_with @project do |format|
        format.html do
          flash[:notice] = notice
          redirect_to @project
        end
        format.js do
          flash[:notice] = notice if @refresh
        end
      end

      track_event 'Updated project', @project.to_tracker.merge({ type: 'project update'})
    else
      initialize_project
      render action: "edit"
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
    redirect_to url_for(Project.last), status: 302
  end

  def submit
    authorize! :edit, @project
    @project.assignment_submitted_at = Time.now
    @project.locked = true
    @project.save
    redirect_to @project, notice: 'Your assignment has been submitted. The project will be locked for modifications until grades are sent out.'
  end

  private
    def initialize_project
      @project.build_logo unless @project.logo
      @project.build_cover_image unless @project.cover_image
    end
end
