class ProjectsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: [:create]
  skip_authorize_resource only: [:embed]
  layout 'project', only: [:edit, :update, :show]
  respond_to :html
  respond_to :js, only: [:edit, :update]
  impressionist actions: [:show], unique: [:impressionable_type, :impressionable_id, :session_hash]
  after_action :allow_iframe, only: :embed

  def index
    title "Explore all projects - Page #{params[:page] || 1}"
    @projects = Project.indexable.last_updated.paginate(page: params[:page])
  end

  def show
    title @project.name
    meta_desc "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on Hackster.io."
    @project = @project.decorate
    @widgets = @project.widgets.order(:created_at)

    track_event 'Viewed project', @project.to_tracker.merge({ own: current_user.try(:is_team_member?, @project) })
  end

  def embed
    title @project.name
    meta_desc "#{@project.one_liner.try(:gsub, /\.$/, '')}. Find this and other hardware projects on Hackster.io."
    @project = @project.decorate
    render layout: false
  end

  def new
    initialize_project
  end

  def edit
    initialize_project
  end

  def create
    @project = Project.new(params[:project])
    @project.private = true

    if @project.save
      @project.team_members.create(user_id: current_user.id)
      flash[:notice] = "#{@project.name} was successfully created."
      respond_with @project

      track_event 'Created project', @project.to_tracker
    else
      initialize_project
      render action: "new"
    end
  end

  def update
    if @project.update_attributes(params[:project])
      if @project.private_changed? and @project.private == false
        current_user.broadcast :new, @project.id, 'Project'

        track_event 'Made project public', @project.to_tracker
      elsif @project.private == false
        current_user.broadcast :update, @project.id, 'Project'
      end
      @project = @project.decorate
      respond_with @project do |format|
        format.html do
          flash[:notice] = "#{@project.name} was successfully updated."
          redirect_to @project
        end
      end

      track_event 'Updated project', @project.to_tracker.merge({ type: 'project update'})
    else
      initialize_project
      render action: "edit"
    end
  end

  def destroy
    @project.destroy

    respond_with current_user
  end

  private
    def allow_iframe
      response.headers.except! 'X-Frame-Options'
    end

    def initialize_project
#      @project.images.new# unless @project.images.any?
#      @project.build_video unless @project.video
      @project.build_logo unless @project.logo
      @project.build_cover_image unless @project.cover_image
    end
end
