class ChallengeIdeasController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :index, :update_workflow, :edit, :update, :destroy]
  before_filter :load_challenge, only: [:create, :new, :edit, :update]
  before_filter :load_and_authorize_idea, only: [:update_workflow, :edit, :update]
  layout :set_layout

  def index
    @challenge = Challenge.find params[:challenge_id]
    authorize! :admin, @challenge
    @ideas = @challenge.ideas.order(:created_at).joins(:user).includes(:image, user: :avatar)

    respond_to do |format|
      format.html do
        @ideas = @ideas.paginate(page: safe_page_params, per_page: 100)
      end
      format.csv do
        @ideas = @ideas.includes(:address)
        file_name = FileNameGenerator.new(@challenge.name, 'ideas')
        headers['Content-Disposition'] = "attachment; filename=\"#{file_name}.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def show
    @challenge = Challenge.find_by_slug! params[:slug]
    @idea = @challenge.ideas.find params[:id]
  end

  def new
    redirect_to @challenge, notice: "Idea submission is currently closed." and return unless @challenge.pre_contest_in_progress?

    @idea = @challenge.ideas.new
    authorize! :create, @idea
  end

  def create
    @idea = @challenge.ideas.new
    authorize! :create, @idea

    @idea.assign_attributes params[:challenge_idea]
    @idea.user_id = current_user.id

    if @idea.save
      @idea.approve! if @challenge.auto_approve?

      session[:share_modal] = 'new_idea_challenge_share_prompt'
      session[:share_modal_model] = 'challenge'
      session[:share_modal_model_id] = @challenge.id
      session[:share_modal_time] = 'after_redirect'

      redirect_to @challenge #, notice: "Your idea has been entered!"
    else
      render :new
    end
  end

  def update_workflow
    if @idea.send "#{params[:event]}!"
      flash[:notice] = "Idea #{event_to_human(params[:event])}."
    else
      flash[:alert] = "Couldn't #{event_to_human(params[:event])} idea."
    end
    redirect_to challenge_admin_ideas_path(@challenge)
  end

  def edit
  end

  def update
    @idea.assign_attributes params[:challenge_idea]
    @idea.workflow_state = :new if @idea.changed? and current_user.id == @idea.user_id and @idea.can_mark_needs_approval?
    if @idea.save
      if current_user.id == @idea.user_id
        redirect_to @challenge, notice: "Your idea was successfully edited."
      else
        redirect_to challenge_admin_ideas_path(@challenge), notice: "Idea successfully edited."
      end
    else
      render :edit
    end
  end

  def destroy
    @idea = ChallengeIdea.find params[:id]
    authorize! :destroy, @idea

    @idea.destroy

    if current_user.id == @idea.user_id
      redirect_to @idea.challenge, notice: "Your idea has been withdrawn."
    else
      redirect_to challenge_admin_ideas_path(@idea.challenge), notice: "Idea deleted."
    end
  end

  private
    def event_to_human event
      case event
      when 'approve'
        'approved'
      when 'mark_won'
        'marked a winner'
      when 'mark_as_shipped'
        'marked as shipped'
      when 'undo_won'
        'unmarked as won'
      else
        "#{event}ed"
      end
    end

    def load_challenge
      @challenge = Challenge.find_by_slug params[:slug]
    end

    def load_and_authorize_idea
      @idea = ChallengeIdea.find params[:id]
      if params[:slug].present?
        raise ActiveRecord::RecordNotFound unless @idea.challenge.slug == params[:slug]
      elsif params[:challenge_id].present?
        raise ActiveRecord::RecordNotFound unless @idea.challenge_id.to_s == params[:challenge_id]
      end
      authorize! self.action_name.to_sym, @idea
      @challenge = @idea.challenge
    end

    def set_layout
      if self.action_name.to_s.in? %w(show)
        'challenge'
      else
        current_layout
      end
    end
end