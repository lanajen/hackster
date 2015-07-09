class FollowersController < ApplicationController
  before_filter :authenticate_user!, except: [:standalone_button]
  respond_to :js, :html
  after_action :allow_iframe, only: :standalone_button

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
end