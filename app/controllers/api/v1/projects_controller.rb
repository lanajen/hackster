class Api::V1::ProjectsController < Api::V1::BaseController
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
    authorize! :create, project

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
      response = {}
      response[:project] = project
      if widgets = PartsWidget.where(widgetable_id: project.id, widgetable_type: 'Project') and widgets.any?
        response[:parts_widgets] = {}
        widgets.each do |widget|
          response[:parts_widgets][widget.id] = {}
          response[:parts_widgets][widget.id][:parts] = {}
          widget.parts.each do |part|
            response[:parts_widgets][widget.id][:parts][part.position] = part
          end
        end
      end
      render json: response.to_json, status: :ok
    else
      errors = project.errors.messages
      widget_errors = {}
      project.widgets.each{|w| widget_errors[w.id] = w.to_error if w.errors.any? }
      errors['widgets'] = widget_errors
      render json: errors, status: :bad_request
    end
  end

  def destroy
    project = Project.find(params[:id])
    authorize! :destroy, project
    project.destroy

    render json: 'Destroyed'
  end
end