class ProjectsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource
  skip_load_resource only: [:create]
  layout 'project', only: [:edit, :update, :show]
  respond_to :html
  respond_to :js, only: [:edit, :update]

  def index
  end

  def show
    title @project.name
    meta_desc "#{@project.one_liner.gsub(/\.$/, '')}. Find this and other hardware projects on hackster.io."
    @project = @project.decorate
    @widgets = @project.widgets.order(:created_at)
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
      flash[:notice] = 'Project was successfully created.'
      respond_with @project
    else
      initialize_project
      render action: "new"
    end
  end

  def update
    if @project.update_attributes(params[:project])
      if @project.private_changed? and @project.private == false
        current_user.broadcast :new, @project.id, 'Project'
      elsif @project.private == false
        current_user.broadcast :update, @project.id, 'Project'
      end
      @project = @project.decorate
      respond_with @project do |format|
        format.html do
          flash[:notice] = 'Project was successfully updated.'
          redirect_to @project
        end
      end
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
    def initialize_project
#      @project.images.new# unless @project.images.any?
#      @project.build_video unless @project.video
      @project.build_logo unless @project.logo
    end
end
