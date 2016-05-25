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
    log_line = LogLine.create(message: message, log_type: '5xx', source: 'api/projects')
    NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification' if ENV['ENABLE_ERROR_NOTIF']
    render status: :internal_server_error, nothing: true
    raise e if Rails.env.development?
  end

  def destroy
    @project.destroy

    render status: :ok, nothing: true
  end

  def description
    if @project.story_json.nil? and @project.description.present?
      render json: { description: @project.decorate.description, story: nil }
    elsif @project.story_json.present?
      render json: { description: nil, story: StoryJsonJsonDecorator.new(@project.story_json).to_json }
    else
      render json: { description: '', story: nil }
    end
  end

  private
    def load_and_authorize_resource
      @project = BaseArticle.find params[:project_id] || params[:id]
      authorize! self.action_name, @project
    end
end
#