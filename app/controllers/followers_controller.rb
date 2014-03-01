class FollowersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_followable
  respond_to :js, :html

  def create
    FollowRelation.add current_user, @followable
    respond_to do |format|
      format.html { redirect_to @followable, notice: "You are now following #{@followable.name}" }
      format.js { render 'button' }
    end
  end

  def destroy
    FollowRelation.destroy current_user, @followable
    respond_to do |format|
      format.html { redirect_to @followable, notice: "You stopped following #{@followable.name}" }
      format.js { render 'button' }
    end
  end

  private
    def load_followable
      render status: :unprocessable_entity and return unless params[:followable_type].in? %w(Project User)

      @followable = params[:followable_type].constantize.find params[:followable_id]
    end
end