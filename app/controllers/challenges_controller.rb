class ChallengesController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :rules]
  before_filter :load_challenge, only: [:show, :rules, :update]
  before_filter :load_tech, only: [:show, :rules]
  before_filter :load_and_authorize_challenge, only: [:enter, :update_workflow]
  before_filter :set_challenge_entrant, only: [:show, :rules]
  load_and_authorize_resource except: [:show, :rules, :update]
  layout :set_layout

  def show
    authorize! :read, @challenge
    title @challenge.name
    per_page = Challenge.per_page
    per_page = per_page - 1 if @challenge.open_for_submissions? and @is_challenge_entrant
    if @challenge.judged?
      @winning_entries = @challenge.entries.winning.includes(:project)
      @other_projects = @challenge.projects.references(:challenge_entries).where("challenge_projects.prize_id IS NULL")
    else
      @projects = @challenge.projects.paginate(page: params[:page], per_page: per_page)
    end
    @embed = Embed.new(url: @challenge.video_link)
  end

  def rules
    authorize! :read, @challenge
    title "#{@challenge.name} rules"
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
      flash[:notice] = "Challenge #{event_to_human(params[:event])}."
    rescue
      flash[:error] = "Couldn't #{params[:event].gsub(/_/, ' ')} challenge, please try again or contact an admin."
    end
    redirect_to @challenge
  end

  private
    def event_to_human event
      case event
      when 'mark_as_judged'
        'marked as judged'
      else
        "#{event}ed"
      end
    end

    def load_challenge
      @challenge = Challenge.find_by_slug! params[:slug]
      @challenge = @challenge.decorate
    end

    def load_and_authorize_challenge
      @challenge = Challenge.find params[:id]
      authorize! self.action_name.to_sym, @challenge
    end

    def load_tech
      @tech = @challenge.tech.try(:decorate)
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