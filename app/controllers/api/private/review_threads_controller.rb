class Api::Private::ReviewThreadsController < Api::Private::BaseController
  before_filter :authenticate_user!

  def show
    thread = ReviewThread.where(project_id: params[:project_id]).first_or_create
    authorize! :read, thread

    render json: { thread: ReviewThreadJsonDecorator.new(thread).node }
  end
end