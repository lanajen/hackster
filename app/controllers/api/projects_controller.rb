class Api::ProjectsController < Api::BaseController
  # before_filter :public_api_methods, only: [:index, :show]

  def index
    render json: Project.order(created_at: :desc).limit(10)
  end

  def show
    project = Project.find params[:id]
    render json: project
  end

  def create
    project = Project.new params[:project]
    authorize! :create, @project

    if project.save
      render json: project, status: :ok
    else
      render json: project.errors, status: :unprocessable_entity
    end
  end

  def update
    project = Project.find params[:id]
    authorize! :update, project

    if project.update_attributes params[:project]
      render json: project, status: :ok
    else
      render json: project.errors, status: :unprocessable_entity
    end
  end

  def destroy
    Project.find(params[:id]).destroy
    authorize! :destroy, @project

    render json: 'Destroyed'
  end
end