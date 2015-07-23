class RespectsController < ApplicationController
  # before_filter :authenticate_user!  # TODO: find something better for anonymous votes than disabling all authentication
  before_filter :find_respectable
  respond_to :html, :json

  def create
    authenticate_user! unless params[:respectable_type] = 'ChallengeEntry'

    @respect = Respect.create_for current_user, @respectable
    # @project = @respect.respectable  # otherwise @project isn't updated
    # @team_members = @respectable.users

    if @respect.persisted?
      if @respect.respectable_type == 'Project'
        session[:share_modal] = 'respected_share_prompt'
        session[:share_modal_model] = 'project'
        event_name = 'Respected project'
      elsif @respect.respectable_type == 'ChallengeEntry'
        @respected = true
        @allow_anonymous_votes = @respectable.challenge.allow_anonymous_votes
      end

      respond_to do |format|
        format.html { redirect_to @respectable, notice: "You respect #{@respectable.name}!" }
        format.js { render 'button' }
      end
    else
      if @respect.respectable_type == 'Project'
        respond_to do |format|
          format.html { redirect_to @respectable, alert: "You can't respect your own project!" }
          format.js { render text: 'alert("You can\'t respect your own project!")', status: :unprocessable_entity }
        end
        event_name = 'Tried respecting own project'
      else
        respond_to do |format|
          format.html { redirect_to @respectable, alert: "You can't vote for your own project!" }
          format.js { render text: 'alert("You can\'t vote for your own project!")', status: :unprocessable_entity }
        end
        event_name = 'Tried voting for own project'
      end
    end

    track_event event_name, @respectable.to_tracker
  end

  def destroy
    authenticate_user! unless params[:respectable_type] = 'ChallengeEntry'

    @respects = Respect.destroy_for current_user, @respectable
    # @project = @respects.first.respectable if @respects.any?  # otherwise @project isn't updated
    # @team_members = @project.users

    if @respectable.class.name == 'Project'
      respond_to do |format|
        format.html { redirect_to @respectable, notice: "You removed #{@respectable.name} from your respect list." }
        format.js { render 'button' }
      end
    else
      track_event 'Disrespected project', @respectable.to_tracker
      respond_to do |format|
        format.html { redirect_to @respectable, notice: "You unvoted #{@respectable.name}." }
        format.js { render 'button' }
      end

      track_event 'Unvoted project', @respectable.to_tracker
    end
  end

  private
    def find_respectable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          return @respectable = $1.classify.constantize.find(value)
        end
      end
    end
end