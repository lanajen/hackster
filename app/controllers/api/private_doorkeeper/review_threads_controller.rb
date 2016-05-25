class Api::PrivateDoorkeeper::ReviewThreadsController < Api::PrivateDoorkeeper::BaseController
  before_action :doorkeeper_authorize_without_scope!

  def show
    thread = ReviewThread.where(project_id: params[:project_id]).first_or_create
    authorize! :read, thread

    opts = { show_unapproved: current_user.is?(:admin, :hackster_moderator, :moderator, :super_moderator) }

    render json: { thread: ReviewThreadJsonDecorator.new(thread).node(opts) }
  end
end