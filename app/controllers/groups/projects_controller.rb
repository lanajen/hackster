class Groups::ProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_group
  respond_to :html
  layout :set_layout

  def new
    @project = @group.projects.new params[:project]
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
    case @group
    when Tech
      @project.tech_tags << TechTag.new(name: @group.tech_tags.first.name)
    else
      @group.projects << @project unless ProjectCollection.exists? @project.id, 'Group', @group.id
    end
    # @project.save

    respond_to do |format|
      format.html { redirect_to group_path(@group), notice: "Your project has been added to #{@group.name}." }
      format.js { render status: :created, json: @group.to_json }
    end
  end

  def unlink
    @project = Project.find params[:project_id]
    case @group
    when Tech
      # @project.tech_tags << TechTag.new(name: @group.tech_tags.first.name)
    else
      @group.projects.destroy @project
    end

    respond_to do |format|
      format.html { redirect_to group_path(@group), notice: "Your project has been removed from #{@group.name}." }
      format.js { render status: :ok, json: @group.to_json }
    end
  end

  private
    def load_group
      @group = if params[:event_name]
        @event = Event.includes(:hackathon).where(groups: { user_name: params[:event_name] }, hackathons_groups: { user_name: params[:user_name] }).first!
      elsif params[:promotion_name]
        load_assignment
      elsif params[:user_name]
        case request.path.split('/')[1]
        when 'communities'
          @community = Community.where(type: 'Community').find_by_user_name! params[:user_name]
        when 'hackerspaces'
          @hacker_space = HackerSpace.find_by_user_name! params[:user_name]
        when 'lists'
          @list = List.where(type: 'List').find_by_user_name! params[:user_name]
        end
      else
        @group = Group.find params[:group_id]
      end
    end

    def set_layout
      case @group
      when Event
        'event'
      else
        'application'
      end
    end
end