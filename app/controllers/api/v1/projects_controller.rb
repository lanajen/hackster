class Api::V1::ProjectsController < Api::V1::BaseController
  # before_filter :public_api_methods, only: [:index, :show]

  def index
    params[:sort] = (params[:sort].in?(Project::SORTING.keys) ? params[:sort] : 'trending')
    by = (params[:by].in?(Project::FILTERS.keys) ? params[:by] : 'all')

    projects = Project.indexable.for_thumb_display
    if params[:sort]
      projects = projects.send(Project::SORTING[params[:sort]])
    end

    if by and by.in? Project::FILTERS.keys
      projects = projects.send(Project::FILTERS[by])
    end

    projects = projects.paginate(page: safe_page_params)

    render json: projects
  end

  def show
    project = Project.find params[:id]
    render json: project
  end

  def create
    project = Project.new params[:project]
    authorize! :create, project

    if project.save
      render json: project, status: :ok
    else
      render json: project.errors, status: :unprocessable_entity
    end
  end

  def update
    @project = Project.find params[:id]
    authorize! :update, @project

    @panel = params[:panel]

    if (params[:save].present? and params[:save] == '0') or @project.update_attributes params[:project]
      # @project = Project.find params[:id]
      if @panel.in? %w(hardware publish team software)
        render 'projects/forms/update'
      else
        render 'projects/forms/checklist', status: :ok
      end
    else
      message = "Couldn't save project: #{@project.inspect} // user: #{current_user.user_name} // params: #{params.inspect} // errors: #{@project.errors.inspect}"
      log_line = LogLine.create(message: message, log_type: '422', source: 'api/projects')
      NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification' if Rails.env == 'production'
      render json: { project: @project.errors }, status: :unprocessable_entity
    end
  rescue => e
    message = "Couldn't save project: #{@project.inspect} // user: #{current_user.user_name} // params: #{params.inspect} // exception: #{e.inspect}"
    log_line = LogLine.create(message: message, log_type: '5xx', source: 'api/projects')
    NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification' if Rails.env == 'production'
    render status: :internal_server_error, nothing: true
  end

  def destroy
    project = Project.find(params[:id])
    authorize! :destroy, project
    project.destroy

    render json: 'Destroyed'
  end
end