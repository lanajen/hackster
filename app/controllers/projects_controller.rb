class ProjectsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource
  skip_load_resource only: [:create]
  layout 'project', only: [:edit, :update, :show]
  respond_to :html

  def index
  end

  def show
    @project = @project.decorate
  end

  def new
    initialize_project
  end

  def edit
    initialize_project
  end

  def create
    @project = Project.new(params[:project])

    if @project.save
      @project.team_members.create(user_id: current_user.id)
      flash[:notice] = 'Project was successfully created.'
      current_user.broadcast :new, @project.id, 'Project'
      respond_with @project
    else
      initialize_project
      render action: "new"
    end
  end

  def update
    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      current_user.broadcast :update, @project.id, 'Project'
      respond_with @project
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
      @project.images.new# unless @project.images.any?
      @project.build_video unless @project.video
      @project.build_logo unless @project.logo
    end
end
