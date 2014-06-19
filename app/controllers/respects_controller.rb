class RespectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_project
  respond_to :html, :json

  def create
    @respect = Respect.create_for current_user, @project
    @project = @respect.project  # otherwise @project isn't updated

    if @respect.persisted?
      respond_to do |format|
        format.html { redirect_to @project, notice: "You respect #{@project.name}!" }
        format.js { render 'button' }
      end
      event_name = 'Respected project'
    else
      respond_to do |format|
        format.html { redirect_to @project, alert: "You can't respect your own project!" }
        format.js { render text: 'alert("You can\'t respect your own project!")' }
      end
      event_name = 'Tried respecting own project'
    end

    track_event event_name, @project.to_tracker
  end

  def destroy
    @respects = Respect.destroy_for current_user, @project
    @project = @respects.first.project if @respects.any?  # otherwise @project isn't updated

    respond_to do |format|
      format.html { redirect_to @project, notice: "You removed #{@project.name} from your respect list." }
      format.js { render 'button' }
    end

    track_event 'Disrespected project', @project.to_tracker
  end
end