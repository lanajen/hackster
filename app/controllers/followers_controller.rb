class FollowersController < ApplicationController
  before_filter :authenticate_user!, except: [:standalone_button]
  before_filter :load_followable, only: [:create]
  respond_to :html
  after_action :allow_iframe, only: :standalone_button

  def create
    FollowRelation.add current_user, @followable

    # case @followable
    # when Platform, List
    #   session[:share_modal] = 'followed_share_prompt'
    #   session[:share_modal_model] = 'followable'
    # when HardwarePart, SoftwarePart, ToolPart, Part
    #   unless current_user.following? @followable.try(:platform)
    #     session[:share_modal] = 'added_to_toolbox_prompt'
    #     session[:share_modal_model] = 'followable'
    #   end
    # end
    # session[:share_modal_time] = 'after_redirect' if session[:share_modal]

    respond_to do |format|
      format.html { redirect_to @followable, notice: "You are now following #{@followable.name}" }
    end

    track_event "Followed #{@followable.class.name}", { id: @followable.id, name: @followable.name, source: params[:source] }
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
      render status: :unprocessable_entity and return unless params[:followable_type].in? %w(Group Part BaseArticle User)

      @followable = params[:followable_type].constantize.find params[:followable_id]
    end
end