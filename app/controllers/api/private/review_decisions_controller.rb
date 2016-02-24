class Api::Private::ReviewDecisionsController < Api::Private::BaseController
  before_filter :authenticate_user!

  def create
    thread = ReviewThread.find_by_project_id! params[:project_id]
    authorize! :update, thread
    decision = thread.decisions.new params[:review_decision]
    decision.user_id = current_user.id

    if decision.save
      render json: { decision: ReviewDecisionJsonDecorator.new(decision).node }
    else
      render status: :unprocessable_entity, json: { errors: decision.errors }
    end
  end
end