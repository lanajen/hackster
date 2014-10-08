class ChallengesController < ApplicationController
  before_filter :load_challenge, only: [:show, :rules, :update]
  before_filter :load_and_authorize_challenge, only: [:enter, :update_workflow]
  load_and_authorize_resource except: [:show, :update]
  layout :set_layout

  def show
    title @challenge.name
    authorize! :read, @challenge
    @challenge = @challenge.decorate
    @projects = @challenge.projects.paginate(page: params[:page])
    @embed = Embed.new(url: @challenge.video_link)
  end

  def rules
    authorize! :read, @challenge
    @challenge = @challenge.decorate
  end

  def edit
  end

  def enter
    @project = Project.find params[:project_id]
    if tag = @challenge.tech.try(:tech_tags).try(:first).try(:name) and !tag.in? @project.tech_tags_cached
      @project.tech_tags << TechTag.new(name: tag)
    end
    @project.private = false
    @project.save
    cp = @challenge.challenge_projects.new
    cp.project_id = @project.id
    if cp.save
      flash[:notice] = "Thanks for entering #{@challenge.name}!"
    else
      flash[:alert] = "Your project couldn't be entered."
    end
    redirect_to @challenge
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

    def set_layout
      if self.action_name.to_s.in? %w(show rules)
        'challenge'
      else
        'application'
      end
    end
end