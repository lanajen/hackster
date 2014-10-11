class ChallengeEntriesController < ApplicationController
  before_filter :authenticate_user!, only: [:edit, :update, :destroy]
  before_filter :load_challenge, only: [:index, :create]
  before_filter :load_and_authorize_entry, only: [:edit, :update, :destroy]
  layout :set_layout

  def index
    authorize! :admin, @challenge
    @entries = @challenge.entries
    @challenge = @challenge.decorate

    # determines how many of each prizes were awarded and how many are left
    if @challenge.judging?
      assigned_prizes = {}
      @entries.pluck(:prize_id).each do |id|
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

    if tag = @challenge.tech.try(:tech_tags).try(:first).try(:name) and !tag.in? @project.tech_tags_cached
      @project.tech_tags << TechTag.new(name: tag)
    end
    @project.private = false
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
    action = params[:current_action]
    if @entry.update_attributes(params[:challenge_entry])
      next_url = case action
      when 'judging'
        if next_entry = @challenge.entries.where("challenge_projects.created_at < ?", @entry.created_at).first
          edit_challenge_entry_path(@challenge, @entry)
        else
          flash[:notice] = "That was the last entry submitted!"
          challenge_entries_path(@challenge)
        end
      else
        user_return_to
      end
      redirect_to next_url
    else
      redirect_to user_return_to, alert: "Couldn't save changes."
    end
  end

  def destroy
    @entry.destroy

    redirect_to @challenge, notice: "Entry deleted."
  end

  private
    def load_challenge
      @challenge = Challenge.find params[:challenge_id]
    end

    def load_and_authorize_entry
      @entry = ChallengeEntry.find params[:id]
      authorize! self.action_name, @entry
      @challenge = @entry.challenge
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