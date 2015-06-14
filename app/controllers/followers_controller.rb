class FollowersController < ApplicationController
  before_filter :authenticate_user!, except: [:standalone_button]
  before_filter :load_followable, only: [:create, :destroy]
  respond_to :js, :html
  after_action :allow_iframe, only: :standalone_button

  def create
    FollowRelation.add current_user, @followable

    case @followable
    when Platform, List
      session[:share_modal] = 'followed_share_prompt'
      session[:share_modal_model] = 'followable'
    when HardwarePart, SoftwarePart, ToolPart, Part
      unless current_user.following? @followable.try(:platform)
        session[:share_modal] = 'added_to_toolbox_prompt'
        session[:share_modal_model] = 'followable'
      end
    end

    respond_to do |format|
      format.html do
        next_url = if @followable == current_platform
          root_path
        else
          @followable
        end
        redirect_to next_url, notice: "You are now following #{@followable.name}"
      end
      format.js do
        render 'button'
      end
    end

    track_event "Followed #{@followable.class.name}", { id: @followable.id, name: @followable.name, source: params[:source] }
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
    @followable = Platform.find params[:id]
    render layout: 'follow_iframe'
  end

  def create_from_button
    @followable = Platform.find params[:id]

    FollowRelation.add current_user, @followable
    respond_to do |format|
      format.html { redirect_to @followable, notice: "You are now following #{@followable.name}" }
      format.js do
        render 'standalone_button'
      end
    end

    track_event "Followed #{@followable.class.name}", { id: @followable.id, name: @followable.name, source: params[:source] }
  end

  private
    def load_followable
      render status: :unprocessable_entity and return unless params[:followable_type].in? %w(Group Part Project User)

      @followable = params[:followable_type].constantize.find params[:followable_id]
    end
end