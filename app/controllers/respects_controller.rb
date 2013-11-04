class RespectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_project
  respond_to :html, :json

  def create
    @respect = Favorite.create_for current_user, @project
    @project = @respect.project  # otherwise @project isn't updated

    respond_to do |format|
      format.html { redirect_to @project, notice: "You respect #{@project.name}!" }
      format.js { render 'button' }
    end

    track_event 'Respected project', @project.to_tracker
  end

  def destroy
    @respects = Favorite.destroy_for current_user, @project
    @project = @respects.first.project if @respects.any?  # otherwise @project isn't updated

    respond_to do |format|
      format.html { redirect_to @project, notice: "You removed #{@project.name} from your respect list." }
      format.js { render 'button' }
    end

    track_event 'Disrespected project', @project.to_tracker
  end
end