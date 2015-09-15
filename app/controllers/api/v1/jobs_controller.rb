class Api::V1::JobsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def show
    job_id = params[:id]
    render json: { status: Sidekiq::Status::status(job_id) }
  end

  def create
    render status: :unprocessable_entity, nothing: true and return unless params[:type].in? %w(compute_reputation)

    job_id = ReputationWorker.perform_async params[:type], params[:user_id] || current_user.id
    render json: { job_id: job_id }, status: :ok
  end
end