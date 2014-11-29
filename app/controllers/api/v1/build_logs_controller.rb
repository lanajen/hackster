class Api::V1::BuildLogsController < Api::V1::BaseController
  # before_filter :public_api_methods, only: [:index, :show]

  def index
    render json: BuildLog.order(created_at: :desc).limit(10)
  end

  def show
    build_log = BuildLog.find params[:id]
    render json: build_log
  end

  def create
    build_log = BuildLog.new params[:build_log]
    authorize! :create, build_log

    if build_log.save
      render json: build_log, status: :ok
    else
      render json: build_log.errors, status: :unprocessable_entity
    end
  end

  def update
    build_log = BuildLog.find params[:id]
    authorize! :update, build_log

    if build_log.update_attributes params[:build_log]
      render json: build_log, status: :ok
    else
      errors = build_log.errors.messages
      widget_errors = {}
      build_log.widgets.each{|w| widget_errors[w.id] = w.to_error if w.errors.any? }
      errors['widgets'] = widget_errors
      render json: errors, status: :bad_request
    end
  end

  def destroy
    build_log = BuildLog.find(params[:id])
    authorize! :destroy, build_log
    build_log.destroy

    render json: 'Destroyed'
  end
end