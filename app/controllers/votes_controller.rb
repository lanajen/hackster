class VotesController < ApplicationController
  # before_filter :authenticate_user!  # TODO: find something better for anonymous votes than disabling all authentication
  before_filter :find_respectable
  respond_to :html, :json

  def create
    @respect = Respect.create_for current_user, @respectable

    if @respect.persisted?
      @respected = true
      @allow_anonymous_votes = @respectable.challenge.allow_anonymous_votes

      respond_to do |format|
        format.html { redirect_to @respectable, notice: "You voted for #{@respectable.name}!" }
        format.js { render 'button' }
      end
    else
      respond_to do |format|
        format.html { redirect_to @respectable, alert: "You can't vote for your own project!" }
        format.js { render text: 'alert("You can\'t vote for your own project!")', status: :unprocessable_entity }
      end
      event_name = 'Tried voting for own project'
    end

    track_event event_name, @respectable.to_tracker
  end

  def destroy
    @respects = Respect.destroy_for current_user, @respectable
    @allow_anonymous_votes = @respectable.challenge.allow_anonymous_votes

    respond_to do |format|
      format.html { redirect_to @respectable, notice: "You unvoted #{@respectable.name}." }
      format.js { render 'button' }
    end

    track_event 'Unvoted project', @respectable.to_tracker
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