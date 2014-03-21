class Groups::ProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_group
  respond_to :html
  layout :set_layout

  def new
    @project = @group.projects.new
    @projects = current_user.projects
  end

  def create
    @project = @group.projects.new params[:project]
    @project.private = true
    @project.build_team
    @project.team.members.new(user_id: current_user.id)

    if @project.save
      flash[:notice] = "#{@project.name} was successfully created."
      respond_with @project

      track_event 'Created project', @project.to_tracker
    else
      @projects = current_user.projects
      render action: "new"
    end
  end

  def link
    @project = Project.find params[:project_id]
    @project.event = @event
    @project.save

    redirect_to group_path(@group), notice: "Your project has been added to #{@group.name}."
  end

  private
    def load_group
      @group = if params[:event_name]
        @event = Event.includes(:hackathon).where(groups: { user_name: params[:event_name] }, hackathons_groups: { user_name: params[:user_name] }).first!
      end
    end

    def set_layout
      case @group
      when Event
        'event'
      end
    end
end