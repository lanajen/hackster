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

    @threads = ReviewThread.joins(:project).where(projects: { private: false }).where.not(review_threads: { workflow_state: :new })
    unless params[:filters].try(:[], :status).present?
      if params[:status] == 'needs_attention'
        @threads = @threads.need_attention
      else
        @threads = @threads.active
      end
    end
    @threads = filter_for @threads, @fields
  end

  def show
    @project = BaseArticle.find params[:id]
    @thread = @project.review_thread
    authorize! :read, @thread
  end
end