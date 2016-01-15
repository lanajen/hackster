class ReviewThreadsController < ApplicationController
  include FilterHelper

  before_filter :authenticate_user!

  def index
    raise CanCan::AccessDenied unless current_user.is? :admin, :moderator, :hackster_moderator

    title "Project review - #{safe_page_params}"
    @fields = {
      'created_at' => 'review_threads.created_at',
      'status' => 'review_threads.workflow_state',
    }

    params[:sort_order] ||= 'ASC'

    @threads = ReviewThread.joins(:project)
    @threads = @threads.active unless params[:filters].try(:[], :status).present?
    @threads = filter_for @threads, @fields
  end

  def show
    @project = BaseArticle.find params[:id]
    @thread = @project.review_thread
    authorize! :read, @thread
  end
end