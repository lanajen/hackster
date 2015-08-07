class ChallengeEntriesController < ApplicationController
  before_filter :authenticate_user!, only: [:edit, :update, :update_workflow, :destroy]
  before_filter :load_challenge, only: [:index, :create]
  before_filter :load_and_authorize_entry, only: [:edit, :update, :update_workflow, :destroy]
  layout :set_layout

  def index
    authorize! :admin, @challenge
    @entries = @challenge.entries.joins(:project)
    @challenge = @challenge.decorate

    # determines how many of each prizes were awarded and how many are left
    if @challenge.judging?
      assigned_prizes = {}
      @entries.joins(:prizes).pluck('prizes.id').each do |id|
        assigned_prizes[id] = 0 unless id.in? assigned_prizes
        assigned_prizes[id] += 1
      end
      @prizes = {}
      @challenge.prizes.each do |prize|
        quantity = prize.quantity - assigned_prizes[prize.id].to_i
        @prizes[prize] = quantity unless quantity.zero?
      end
    end
  end

  def create
    authorize! :enter, @challenge

    @project = Project.find params[:project_id]
    authorize! :enter_in_challenge, @project

    if tag = @challenge.platform.try(:platform_tags).try(:first).try(:name) and !tag.in? @project.platform_tags_cached
      @project.platform_tags << PlatformTag.new(name: tag)
    end
    @project.private = false
    @project.workflow_state = 'idea' if @challenge.project_ideas
    @project.save
    entry = @challenge.entries.new
    entry.user_id = current_user.id
    entry.project_id = @project.id
    if entry.save
      entry.approve! if @challenge.auto_approve?
      flash[:notice] = "Thanks for entering #{@challenge.name}!"
    else
      flash[:alert] = "Your project couldn't be entered."
    end
    redirect_to @challenge
  end

  def edit
    @project = @entry.project
  end

  def update
    if @entry.update_attributes(params[:challenge_entry])
      next_url = case params[:current_action]
      when 'judging'
        if params[:commit] == 'Save'
          flash[:notice] = "Changes saved."
          challenge_entries_path(@challenge)
        else
          if next_entry = @challenge.entries.where.not(challenge_projects: { id: @entry.id }).where(challenge_projects: { prize_id: nil }).joins(:project).first
            edit_challenge_entry_path(@challenge, next_entry)
          else
            flash[:notice] = "That was the last entry submitted!"
            challenge_entries_path(@challenge)
          end
        end
      else
        user_return_to
      end
      redirect_to next_url
    else
      redirect_to user_return_to, alert: "Couldn't save changes."
    end
  end

  def update_workflow
    if @entry.send "#{params[:event]}!"
      flash[:notice] = "Entry #{event_to_human(params[:event])}."
    else
      flash[:alert] = "Couldn't #{event_to_human(params[:event])} entry."
    end
    redirect_to challenge_entries_path(@challenge)
  end

  def destroy
    @entry.destroy

    redirect_to challenge_entries_path, notice: "Entry deleted."
  end

  private
    def event_to_human event
      case event
      when 'approve'
        'approved'
      else
        "#{event}ed"
      end
    end

    def load_challenge
      @challenge = Challenge.find params[:challenge_id]
    end

    def load_and_authorize_entry
      @entry = ChallengeEntry.find params[:id]
      authorize! self.action_name.to_sym, @entry
      @challenge = @entry.challenge
    end

    def set_challenge_entrant
      @is_challenge_entrant = (user_signed_in? and current_user.is_challenge_entrant? @challenge)
    end

    def set_layout
      if self.action_name.to_s.in? %w(show rules)
        'challenge'
      else
        current_layout
      end
    end
end