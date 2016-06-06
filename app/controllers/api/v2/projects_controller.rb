class Api::V2::ProjectsController < Api::V2::BaseController
  before_filter -> { doorkeeper_authorize! :write_project }
  before_filter :load_and_authorize_resource

  def create
    if project.save
      render status: :ok, nothing: true
    else
      render json: project.errors, status: :unprocessable_entity
    end
  end

  def update
    @project.assign_attributes(params[:base_article])
    did_change = @project.changed?
    changed = @project.changed

    if @project.save
      ProjectWorker.perform_async 'create_review_event', @project.id, current_user.id, :project_update, changed: changed if did_change
      render status: :ok, nothing: true
    else
      render json: { base_article: @project.errors }, status: :unprocessable_entity
    end

  rescue => e
    message = "Couldn't save project: #{@project.inspect} // user: #{current_user.try(:user_name)} // params: #{params.inspect} // exception: #{e.inspect}"
    AppLogger.new(message, '5xx', 'api/projects', e).log_and_notify_with_stdout
    render status: :internal_server_error, nothing: true
    raise e if Rails.env.development?
  end

  def destroy
    @project.destroy

    render status: :ok, nothing: true
  end

  private
    def load_and_authorize_resource
      @project = BaseArticle.find params[:project_id] || params[:id]
      authorize! self.action_name, @project
    end
end
#
