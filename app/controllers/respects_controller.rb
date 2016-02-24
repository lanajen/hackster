class RespectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_respectable
  respond_to :html, :json

  def create
    @respect = Respect.create_for current_user, @respectable
    if @respectable.model_name.name == 'BaseArticle'
      @team_members = @respectable.users  # used by rewardino.rb for badges
    end

    if @respect.persisted?
      session[:share_modal] = 'respected_share_prompt'
      session[:share_modal_model] = 'project'
      event_name = 'Respected project'

      respond_to do |format|
        format.html { redirect_to @respectable, notice: "You respect #{@respectable.name}!" }
        format.js { render 'button' }
      end
    else
      respond_to do |format|
        format.html { redirect_to @respectable, alert: "You can't respect your own project!" }
        format.js { render text: 'alert("You can\'t respect your own project!")', status: :unprocessable_entity }
      end
      event_name = 'Tried respecting own project'
    end

    track_event event_name, @respectable.to_tracker
  end

  def destroy
    @respects = Respect.destroy_for current_user, @respectable
    if @respectable.model_name.name == 'BaseArticle'
      @team_members = @respectable.users  # used by rewardino.rb for badges
    end

    respond_to do |format|
      format.html { redirect_to @respectable, notice: "You removed #{@respectable.name} from your respect list." }
      format.js { render 'button' }
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