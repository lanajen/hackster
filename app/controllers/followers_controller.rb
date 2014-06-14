class FollowersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_followable
  respond_to :js, :html

  def create
    FollowRelation.add current_user, @followable
    respond_to do |format|
      format.html { redirect_to @followable, notice: "You are now following #{@followable.name}" }
      format.js do
        @partial = get_partial
        render 'button'
      end
    end

    track_event "Followed #{@followable.class.name}", { id: @followable.id, name: @followable.name }
  end

  def destroy
    FollowRelation.destroy current_user, @followable
    respond_to do |format|
      format.html { redirect_to @followable, notice: "You stopped following #{@followable.name}" }
      format.js do
        @partial = get_partial
        render 'button'
      end
    end

    track_event "Unfollowed #{@followable.class.name}", { id: @followable.id, name: @followable.name }
  end

  private
    def get_partial
      case @followable
      when Group, User
        'button_text'
      else
        'button'
      end
    end

    def load_followable
      render status: :unprocessable_entity and return unless params[:followable_type].in? %w(Group Project User)

      @followable = params[:followable_type].constantize.find params[:followable_id]
    end
end