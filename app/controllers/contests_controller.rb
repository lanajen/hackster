class ContestsController < ApplicationController
  before_filter :load_contest, only: [:show, :rules, :update]
  before_filter :load_and_authorize_contest, only: [:enter, :update_workflow]
  load_and_authorize_resource except: [:show, :update]
  layout :set_layout

  def show
    authorize! :read, @contest
    @contest = @contest.decorate
    @projects = @contest.projects.paginate(page: params[:page])
    @embed = Embed.new(url: @contest.video_link)
  end

  def rules
    authorize! :read, @contest
    @contest = @contest.decorate
  end

  def edit
  end

  def enter
    @project = Project.find params[:project_id]
    if tag = @contest.tech.try(:tech_tags).try(:first).try(:name) and !tag.in? @project.tech_tags_cached
      @project.tech_tags << TechTag.new(name: tag)
    end
    @project.private = false
    @project.save
    cp = @contest.contest_projects.new
    cp.project_id = @project.id
    if cp.save
      flash[:notice] = "Thanks for entering #{@contest.name}!"
    else
      flash[:alert] = "Your project couldn't be entered."
    end
    redirect_to @contest
  end

  def update
    authorize! :update, @contest
    if @contest.update_attributes(params[:contest])
      redirect_to @contest, notice: 'Changes saved.'
    else
      render 'edit'
    end
  end

  def update_workflow
    begin
      @contest.send "#{params[:event]}!"
      flash[:notice] = "Contest #{params[:event]}ed"
    rescue
      flash[:error] = "Couldn't #{params[:event]} contest, please try again or contact an admin."
    end
    redirect_to @contest
  end

  private
    def load_contest
      @contest = Contest.find_by_slug! params[:slug]
      @contest = @contest.decorate
    end

    def load_and_authorize_contest
      @contest = Contest.find params[:id]
      authorize! self.action_name.to_sym, @contest
    end

    def set_layout
      if self.action_name.to_s.in? %w(show rules)
        'contest'
      else
        'application'
      end
    end
end