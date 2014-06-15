class ProjectsController < ApplicationController
  before_filter :load_project, only: [:show, :embed, :update, :destroy, :redirect_old_show_route]
  load_and_authorize_resource only: [:index, :create, :new, :edit]
  layout 'project', only: [:edit, :update, :show]
  respond_to :html
  respond_to :js, only: [:edit, :update]
  after_action :allow_iframe, only: :embed

  def index
    title "Explore all projects - Page #{params[:page] || 1}"

    params[:sort] ||= 'magic'
    @by = params[:by] || 'all'

    @projects = Project.indexable
    if params[:sort] and params[:sort].in? Project::SORTING.keys
      @projects = @projects.send(Project::SORTING[params[:sort]])
    end

    if params[:by] and params[:by].in? Project::FILTERS.keys
      @projects = @projects.send(Project::FILTERS[params[:by]])
    end

    @projects = @projects.paginate(page: params[:page])

    respond_to do |format|
      format.html
      format.atom { render layout: false }
      format.rss { redirect_to projects_path(params.merge(format: :atom)), status: :moved_permanently }
    end
  end

  def show
    authorize! :read, @project
    impressionist_async @project, '', unique: [:session_hash]

    @show_part_of = @project.collection_id.present? and @project.assignment.present?

    title @project.name
    @project_meta_desc = "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on Hackster.io."
    meta_desc @project_meta_desc
    @project = @project.decorate
    @widgets = @project.widgets.order(:created_at)

    # other projects by same author
    @other_projects_count = Project.public.most_popular.includes(:team_members).references(:members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: @project.id).size
    if @other_projects_count > 6
      @other_projects = Project.public.most_popular.includes(:team_members).references(:members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: @project.id).limit(3)
      @last_projects = Project.public.last_public.includes(:team_members).references(:members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: [@project.id] + @other_projects.map(&:id)).limit(3)
    else
      @other_projects = Project.public.most_popular.includes(:team_members).references(:members).where(members:{user_id: @project.users.pluck(:id)}).where.not(id: @project.id)
    end
    @issue = Feedback.where(threadable_type: 'Project', threadable_id: @project.id).first if @project.collection_id.present? and @project.assignment.present?

    # next/previous project in search
    if params[:ref] and params[:ref_id] and params[:offset]
      offset = params[:offset].to_i
      case params[:ref]
      when 'assignment'
        if @assignment = Assignment.find_by_id(params[:ref_id])
          @next = @assignment.projects.order(:created_at).offset(offset + 1).first
          @prev = @assignment.projects.order(:created_at).offset(offset - 1).first unless offset.zero?
        end
      when 'explore'
        sort, by = params[:ref_id].split(/_/)

        @projects = Project
        if sort.in? Project::SORTING.keys
          @projects = @projects.send(Project::SORTING[sort])
        end

        if by.in? Project::FILTERS.keys
          @projects = @projects.send(Project::FILTERS[by])
        end

        @next = @projects.indexable.offset(offset + 1).first
        @prev = @projects.indexable.offset(offset - 1).first unless offset.zero?

      when 'event'
        if @event = Event.find_by_id(params[:ref_id])
          @next = @event.projects.live.order('projects.respects_count DESC').offset(offset + 1).first
          @prev = @event.projects.live.order('projects.respects_count DESC').offset(offset - 1).first unless offset.zero?
        end

      when 'search'
        params[:q] = params[:ref_id]
        params[:type] = 'project'
        params[:per_page] = 1
        params[:offset] = offset + 1
        params[:include_external] = false
        @next = SearchRepository.new(params).search.results.first
        unless offset.zero?
          params[:offset] = offset - 1
          @prev = SearchRepository.new(params).search.results.first
        end
        params[:offset] = offset
        params.delete(:include_external)
      when 'user'
        if @user = User.find_by_id(params[:ref_id])
          @next = @user.projects.live.order(start_date: :desc, created_at: :desc).offset(offset + 1).first
          @prev = @user.projects.live.order(start_date: :desc, created_at: :desc).offset(offset - 1).first unless offset.zero?
        end
      end
    end

    track_event 'Viewed project', @project.to_tracker.merge({ own: !!current_user.try(:is_team_member?, @project) })
  end

  def show_external
    @project = Project.external.find_by_id!(params[:id]).decorate
    impressionist_async @project, '', unique: [:session_hash]
    title @project.name
    meta_desc @project.one_liner
    track_event 'Viewed project', @project.to_tracker.merge({ own: !!current_user.try(:is_team_member?, @project) })
  end

  def redirect_external
    @project = Project.external.find_by_slug!(params[:slug])
    redirect_to external_project_path(@project), status: 301
  end

  def claim_external
    @project = Project.external.find_by_id!(params[:id]).decorate
    authorize! :claim, @project

    @project.build_team
    @project.team.members.new(user_id: current_user.id)
    # @project.guest_name = nil
    @project.approved = nil
    @project.save

    redirect_to external_project_path(@project), notice: "You just claimed #{@project.name}. We'll let you know when it's approved!"
  end

  def get_xframe_options
    embed = !get_xframe_options_for(params[:url]).in?(%w(SAMEORIGIN DENY))

    render json: embed.to_json
  end

  def embed
    title @project.name
    meta_desc "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on Hackster.io."
    @project = @project.decorate
    render layout: 'embed'

    track_event 'Rendered embed thumbnail', @project.to_tracker.merge({ referrer: request.referrer })
  end

  def new
    initialize_project
    event = if @project.external
      'Attempted to submit a link'
    else
      'Attempted to create a project'
    end

    track_event event
  end

  def edit
    authorize! :update, @project

    initialize_project
  end

  def create
    if @project.external
      event = 'Submitted link'
    else
      @project.approved = true
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
        respond_with @project
      end

      track_event event, @project.to_tracker
    else
      initialize_project
      render action: "new"
    end
  end

  def update
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

  def redirect_old_show_route
    redirect_to url_for(@project), status: 301
  end

  def redirect_to_last
    redirect_to url_for(Project.last), status: 302
  end

  private
    def get_xframe_options_for url
      u = URI.parse(url)
      http = Net::HTTP.new(u.host, u.port)
      http.use_ssl = true if u.scheme == 'https'
      # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res = http.request_head(u.request_uri)

      res['X-Frame-Options']
    rescue => e
      e.message
    end

    def initialize_project
#      @project.images.new# unless @project.images.any?
#      @project.build_video unless @project.video
      @project.build_logo unless @project.logo
      @project.build_cover_image unless @project.cover_image
    end
end