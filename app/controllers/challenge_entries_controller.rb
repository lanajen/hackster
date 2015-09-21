class ChallengeEntriesController < ApplicationController
  before_filter :authenticate_user!, only: [:edit, :update, :update_workflow, :destroy]
  before_filter :load_challenge, only: [:index, :create]
  before_filter :load_and_authorize_entry, only: [:edit, :update, :update_workflow, :destroy]
  layout :set_layout

  def index
    authorize! :admin, @challenge
    @entries = @challenge.entries.joins(:project, :user).includes(:prizes, user: :avatar, project: :team).order(:created_at)
    @challenge = @challenge.decorate

    @approved_entries_count = @entries.where(workflow_state: ChallengeEntry::APPROVED_STATES).count
    @rejected_entries_count = @entries.where(workflow_state: 'unqualified').count
    @new_entries_count = @entries.where(workflow_state: 'new').count

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
    entry = @challenge.entries.new
    authorize! :create, entry

    @project = Project.find params[:project_id]
    authorize! :enter_in_challenge, @project

    @project.private = false
    @project.workflow_state = 'idea' if @challenge.project_ideas
    @project.save

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
      when 'moderating'
        if params[:commit] == 'Save'
          flash[:notice] = "Changes saved."
          challenge_entries_path(@challenge)
        else
          if next_entry = @challenge.entries.where(workflow_state: :new).first
            edit_challenge_entry_path(@challenge, next_entry)
          else
            flash[:notice] = "That was the last entry needing moderation!"
            challenge_entries_path(@challenge)
          end
        end
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

    if current_user.id == @entry.user_id
      redirect_to challenge_path(@challenge), notice: "Your entry has been withdrawn."
    else
      redirect_to challenge_entries_path(@challenge), notice: "Entry deleted."
    end
  end

  private
    def event_to_human event
      case event
      when 'approve'
        'approved'
      when 'disqualify'
        'disqualified'
      else
        "#{event}ed"
      end
    end

    def load_challenge
      @challenge = Challenge.find params[:challenge_id]
    end

    def load_and_authorize_entry
      @entry = ChallengeEntry.find params[:id]
      raise ActiveRecord::RecordNotFound unless params[:challenge_id] == @entry.challenge_id.to_s
      authorize! self.action_name.to_sym, @entry
      @challenge = @entry.challenge
    end

    def set_layout
      if self.action_name.to_s.in? %w(show rules)
        'challenge'
      else
        current_layout
      end
    end
end