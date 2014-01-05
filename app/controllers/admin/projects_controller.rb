class Admin::ProjectsController < Admin::BaseController
  def index
    title "Admin > Projects - #{params[:page]}"
    @fields = {
      'name' => 'projects.name',
      'private' => 'projects.private',
      'created_at' => 'projects.created_at',
    }

    params[:sort_order] ||= 'DESC'

    @projects = filter_for Project, @fields
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])

    if @project.save
      redirect_to admin_projects_path, :notice => 'New project created'
    else
      render :new
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])

    if @project.update_attributes(params[:project])
      redirect_to admin_projects_path, :notice => 'Project successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to admin_projects_path, :notice => 'Project successfuly deleted'
  end
end