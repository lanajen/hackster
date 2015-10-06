class ChallengeIdeasController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :update_workflow, :destroy]
  before_filter :load_challenge, only: [:create, :new]
  before_filter :load_and_authorize_idea, only: [:update_workflow]
  layout :set_layout

  def new
    @idea = @challenge.ideas.new
    authorize! :create, @idea
  end

  def create
    @idea = @challenge.ideas.new
    authorize! :create, @idea

    @idea.assign_attributes params[:challenge_idea]
    @idea.user_id = current_user.id

    if @idea.save
      idea.approve! if @challenge.auto_approve?
      flash[:notice] = "Your idea has been entered!"
      redirect_to @challenge
    else
      render :new
    end
  end

  # def update_workflow
  #   if @idea.send "#{params[:event]}!"
  #     flash[:notice] = "Idea #{event_to_human(params[:event])}."
  #   else
  #     flash[:alert] = "Couldn't #{event_to_human(params[:event])} idea."
  #   end
  #   redirect_to challenge_ideas_path(@challenge)
  # end

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
    # def event_to_human event
    #   case event
    #   when 'approve'
    #     'approved'
    #   when 'disqualify'
    #     'disqualified'
    #   else
    #     "#{event}ed"
    #   end
    # end

    def load_challenge
      @challenge = Challenge.find_by_slug params[:slug]
    end

    def load_and_authorize_idea
      @idea = ChallengeIdea.find_by_slug params[:slug]
      authorize! self.action_name.to_sym, @idea
      @challenge = @idea.challenge
      raise ActiveRecord::RecordNotFound unless @challenge.slug == params[:slug]
    end

    def set_layout
      if self.action_name.to_s.in? %w(index)
        'challenge'
      else
        current_layout
      end
    end
end