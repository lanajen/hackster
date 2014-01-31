class Admin::ProjectsController < Admin::BaseController
  load_resource except: :index
  def index
    title "Admin > Projects - #{params[:page]}"
    @fields = {
      'created_at' => 'projects.created_at',
      'made_public_at' => 'projects.made_public_at',
      'name' => 'projects.name',
      'private' => 'projects.private',
    }

    params[:sort_order] ||= 'DESC'

    @projects = filter_for Project, @fields
  end

  def new
  end

  def create
    if @project.save
      redirect_to admin_projects_path, :notice => 'New project created'
    else
      render :new
    end
  end

  def edit
    title "Admin > Projects > Edit #{@project.name}"
  end

  def update
    if @project.update_attributes(params[:project])
      redirect_to admin_projects_path, :notice => 'Project successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to admin_projects_path, :notice => 'Project successfuly deleted'
  end
end