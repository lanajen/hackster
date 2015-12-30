class Api::V1::ReviewThreadsController < Api::V1::BaseController
  def show
    thread = ReviewThread.where(project_id: params[:project_id]).first_or_create

    render json: { thread: { decisions: thread.decisions, comments: thread.comments, updates: [] } }
  end
end