class Admin::ProjectsController < Admin::BaseController
  load_resource except: [:index, :new, :create]

  def index
    title "Admin / Projects - #{safe_page_params}"
    @fields = {
      'created_at' => 'projects.created_at',
      'made_public_at' => 'projects.made_public_at',
      'status' => 'projects.workflow_state',
      'private' => 'projects.private',
      'name' => 'projects.name',
      'type' => 'projects.type',
    }

    params[:sort_order] ||= 'DESC'

    @projects = params[:approval_needed] ? Project.need_review : Project
    @projects = filter_for @projects, @fields
  end

  def new
    title "Admin / Projects / New"

    model_class = if params[:type] and params[:type].in? Project::MACHINE_TYPES.keys
      Project::MACHINE_TYPES[params[:type]].constantize
    else
      Project
    end
    @project = model_class.new params[:project]
  end

  def create
    model_class = if params[:project] and params[:project][:type] and params[:project][:type].in? Project::MACHINE_TYPES.values
      params[:project][:type].constantize
    else
      Project
    end
    @project = model_class.new params[:project]

    if @project.save
      redirect_to admin_projects_path, :notice => 'New project created'
    else
      render :new
    end
  end

  def edit
    title "Admin / Projects / Edit #{@project.name}"
  end

  def update
    if @project.update_attributes(params[:project])
      @team_members = @project.users
      redirect_to admin_projects_path, :notice => 'Project successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to admin_projects_path, :notice => 'Project successfuly deleted'
  end

  private
    def check_authorization_for_admin
      raise CanCan::AccessDenied unless current_user.is? :admin, :moderator
    end
end