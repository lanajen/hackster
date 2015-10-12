class ChallengeIdeasController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :index, :update_workflow, :edit, :update, :destroy]
  before_filter :load_challenge, only: [:create, :new, :edit, :update]
  before_filter :load_and_authorize_idea, only: [:update_workflow, :edit, :update]
  layout :set_layout

  def index
    @challenge = Challenge.find params[:challenge_id]
    authorize! :admin, @challenge
    @ideas = @challenge.ideas.order(:created_at).includes(user: :avatar)

    respond_to do |format|
      format.html do
      end
      format.csv do
        file_name = FileNameGenerator.new(@challenge.name, 'ideas')
        headers['Content-Disposition'] = "attachment; filename=\"#{file_name}.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def show
    @challenge = Challenge.find params[:challenge_id]
    authorize! :admin, @challenge
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
      redirect_to @challenge, notice: "Your idea has been entered!"
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
      redirect_to challenge_ideas_path(@challenge), notice: "Idea deleted."
    end
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
      @challenge = Challenge.find_by_slug params[:slug]
    end

    def load_and_authorize_idea
      @idea = ChallengeIdea.find params[:id]
      if params[:slug].present?
        raise ActiveRecord::RecordNotFound unless @idea.challenge.slug == params[:slug]
      else
        raise ActiveRecord::RecordNotFound unless @idea.challenge_id.to_s == params[:challenge_id]
      end
      authorize! self.action_name.to_sym, @idea
      @challenge = @idea.challenge
    end

    def set_layout
      if self.action_name.to_s.in? %w()
        'challenge'
      else
        current_layout
      end
    end
end