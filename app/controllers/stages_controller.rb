class StagesController < ApplicationController
  before_filter :authenticate_user!
  load_resource
  respond_to :html

  def update_workflow
    authorize! :update, @stage

    if @stage.send "#{params[:event]}!"
      flash[:notice] = "Stage status updated."
    else
      flash[:alert] = "Couldn't update stage status."
    end

  rescue Workflow::NoTransitionAllowed
    flash[:alert] = "Couldn't update stage status."
  ensure
    redirect_to params[:redirect_to] || session[:user_return_to]
  end
end