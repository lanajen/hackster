class FollowersController < ApplicationController
  before_filter :authenticate_user!, except: [:standalone_button]
  before_filter :load_followable, only: [:create, :destroy]
  respond_to :js, :html
  after_action :allow_iframe, only: :standalone_button

  def create
    FollowRelation.add current_user, @followable
    respond_to do |format|
      format.html { redirect_to @followable, notice: "You are now following #{@followable.name}" }
      format.js do
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
        render 'button'
      end
    end

    track_event "Unfollowed #{@followable.class.name}", { id: @followable.id, name: @followable.name }
  end

  def standalone_button
    @followable = Tech.find params[:id]
    render layout: 'follow_iframe'
  end

  def create_from_button
    @followable = Tech.find params[:id]

    FollowRelation.add current_user, @followable
    respond_to do |format|
      format.html { redirect_to @followable, notice: "You are now following #{@followable.name}" }
      format.js do
        render 'standalone_button'
      end
    end

    track_event "Followed #{@followable.class.name}", { id: @followable.id, name: @followable.name }
  end

  private
    def load_followable
      render status: :unprocessable_entity and return unless params[:followable_type].in? %w(Group Project User)

      @followable = params[:followable_type].constantize.find params[:followable_id]
    end
end