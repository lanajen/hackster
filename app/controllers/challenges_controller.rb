class ChallengesController < ApplicationController
  before_filter :load_challenge, only: [:show, :rules, :update]
  before_filter :load_and_authorize_challenge, only: [:enter, :update_workflow]
  before_filter :set_challenge_entrant, only: [:show, :rules]
  load_and_authorize_resource except: [:show, :rules, :update]
  layout :set_layout

  def show
    title @challenge.name
    authorize! :read, @challenge
    # @challenge = @challenge.decorate
    per_page = Challenge.per_page
    per_page = per_page - 1 if @challenge.open_for_submissions? and @is_challenge_entrant
    @projects = @challenge.projects.paginate(page: params[:page], per_page: per_page)
    @embed = Embed.new(url: @challenge.video_link)
  end

  def rules
    authorize! :read, @challenge
    # @challenge = @challenge.decorate
  end

  def edit
  end

  def update
    authorize! :update, @challenge
    if @challenge.update_attributes(params[:challenge])
      redirect_to @challenge, notice: 'Changes saved.'
    else
      render 'edit'
    end
  end

  def update_workflow
    begin
      @challenge.send "#{params[:event]}!"
      flash[:notice] = "Challenge #{params[:event]}ed"
    rescue
      flash[:error] = "Couldn't #{params[:event]} challenge, please try again or contact an admin."
    end
    redirect_to @challenge
  end

  private
    def load_challenge
      @challenge = Challenge.find_by_slug! params[:slug]
      @challenge = @challenge.decorate
    end

    def load_and_authorize_challenge
      @challenge = Challenge.find params[:id]
      authorize! self.action_name.to_sym, @challenge
    end

    def set_challenge_entrant
      @is_challenge_entrant = (user_signed_in? and current_user.is_challenge_entrant? @challenge)
    end

    def set_layout
      if self.action_name.to_s.in? %w(show rules)
        'challenge'
      else
        'application'
      end
    end
end