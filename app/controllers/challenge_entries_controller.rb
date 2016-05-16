class ChallengeEntriesController < ApplicationController
  before_filter :authenticate_user!, only: [:edit, :update, :update_workflow, :destroy]
  before_filter :load_challenge, only: [:index, :create, :new]
  before_filter :load_entry, only: [:update]
  before_filter :load_and_authorize_entry, only: [:edit, :update_workflow, :destroy]
  layout :set_layout

  def index
    authorize! :admin, @challenge
    @entries = @challenge.entries.joins(:project, :user).includes(:prizes, user: :avatar, project: :team).order(:created_at)
    if params[:status]
      @entries = @entries.where workflow_state: params[:status]
    end

    respond_to do |format|
      format.html do
        @challenge = @challenge.decorate
        @entries = @entries.paginate(page: safe_page_params, per_page: 100)
      end
    end
  end

  def new
    authorize! :admin, @challenge
    @entry = @challenge.entries.new
  end

  def create
    if params[:admin]
      authorize! :admin, @challenge

      @entry = @challenge.entries.new
      @entry.assign_attributes params[:challenge_entry]
      if @entry.save
        redirect_to new_challenge_admin_entry_path(@challenge), notice: "The project was successfuly entered to the #{@challenge.self_label.downcase}."
      else
        render :new
      end

    else
      entry = @challenge.entries.new
      authorize! :create, entry

      @project = BaseArticle.find params[:project_id]
      authorize! :enter_in_challenge, @project

      entry.assign_attributes params[:challenge_entry]
      entry.user_id = current_user.id
      entry.project_id = @project.id

      next_url = @challenge

      if entry.save
        flash[:notice] = "Your project was added to #{@challenge.name}. Please submit it when ready."
      else
        flash[:alert] = "Your project couldn't be entered."
      end

      redirect_to next_url
    end
  end

  def edit
    @project = @entry.project
  end

  def update
    @entry.assign_attributes(params[:challenge_entry])
    authorize! :update, @entry

    if @entry.save
      next_url = case params[:current_action]
      when 'submitting'
        @entry.project.update_attribute :private, false
        @entry.approve! if @challenge.auto_approve?

        session[:share_modal] = 'new_entry_challenge_share_prompt'
        session[:share_modal_model] = 'challenge'
        session[:share_modal_model_id] = @challenge.id
        session[:share_modal_time] = 'after_redirect'

        @challenge
      when 'moderating'
        if params[:commit] == 'Save'
          flash[:notice] = "Changes saved."
          challenge_admin_entries_path(@challenge)
        else
          if next_entry = @challenge.entries.where(workflow_state: :new).first
            edit_challenge_entry_path(@challenge, next_entry)
          else
            flash[:notice] = "That was the last entry needing moderation!"
            challenge_admin_entries_path(@challenge)
          end
        end
      when 'judging'
        if params[:commit] == 'Save'
          flash[:notice] = "Changes saved."
          challenge_admin_entries_path(@challenge)
        else
          if next_entry = @challenge.entries.where.not(challenge_projects: { id: @entry.id, workflow_state: :unqualified }).where(challenge_projects: { prize_id: nil }).joins(:project).order(:created_at).first
            edit_challenge_entry_path(@challenge, next_entry)
          else
            flash[:notice] = "That was the last entry submitted!"
            challenge_admin_entries_path(@challenge)
          end
        end
      else
        user_return_to
      end
      redirect_to next_url
    elsif params[:current_action] == 'submitting'
      if :category_id.in? @entry.errors.keys
        flash[:alert] = "Please select a category"
        redirect_to challenge_path(@challenge, submit: @entry.id)
      elsif @entry.errors.keys.select{|v| v =~ /cfield/ }.any?
        flash[:alert] = "Please answer all questions"
        redirect_to challenge_path(@challenge, submit: @entry.id)
      else
        redirect_to user_return_to, alert: "Couldn't submit project, please try again or contact us at help@hackster.io for assistance."
      end
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
    redirect_to challenge_admin_entries_path(@challenge)
  end

  def destroy
    @entry.destroy

    if current_user.id == @entry.user_id
      redirect_to challenge_path(@challenge), notice: "Your entry has been withdrawn."
    else
      redirect_to challenge_admin_entries_path(@challenge), notice: "Entry deleted."
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

    def load_entry
      @entry = ChallengeEntry.find params[:id]
      raise ActiveRecord::RecordNotFound unless params[:challenge_id] == @entry.challenge_id.to_s
      @challenge = @entry.challenge
    end

    def load_and_authorize_entry
      load_entry
      authorize! self.action_name.to_sym, @entry
    end

    def set_layout
      if self.action_name.to_s.in? %w(show rules)
        'challenge'
      else
        current_layout
      end
    end
end