class Groups::ProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_group
  respond_to :html
  # layout :set_layout

  def index
    authorize! :moderate, @group

    @pending_review_size = @group.project_collections.where(workflow_state: :pending_review).size

    @project_collections = @group.project_collections.joins(:project)

    if params[:status] and params[:status].in? %w(approved rejected pending_review featured)
      @project_collections = @project_collections.where(workflow_state: params[:status])
    end

    if params[:q].present?
      q = "%#{params[:q]}%"
      @project_collections = @project_collections.joins(:project).where("projects.name ILIKE ?", q)
    end

    @project_collections = @project_collections.includes(:project).includes(project: :users).order(created_at: :desc).paginate(page: params[:page])
  end

  def new
    @project = @group.projects.new params[:base_article]
    @projects = current_user.projects
  end

  def create
    @project = @group.projects.new params[:base_article]
    @project.pryvate = true
    @project.build_team
    @project.team.members.new(user_id: current_user.id)

    if @project.save
      flash[:notice] = "#{@project.name} was successfully created."
      respond_with @project, location: edit_project_path(@project)

      track_event 'Created project', @project.to_tracker
    else
      @projects = current_user.projects
      render action: "new"
    end
  end

  def featured
    authorize! :moderate, @group

    @projects = @group.project_collections.featured.includes(:project)
  end

  def save_featured
    authorize! :moderate, @group

    if @group.update_attributes(params[:group])
      redirect_to group_admin_projects_path(@group), notice: 'Featured projects saved.'
    else
      @projects = @group.project_collections.featured.includes(:project)
      render :featured
    end
  end

  def link
    @project = BaseArticle.find params[:project_id]
    case @group
    when Platform
      @project.platform_tags << PlatformTag.new(name: @group.platform_tags.first.name)
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
    @project = BaseArticle.find params[:project_id]
    case @group
    when Platform
      # @project.platform_tags << PlatformTag.new(name: @group.platform_tags.first.name)
    else
      @group.projects.destroy @project
    end

    respond_to do |format|
      format.html { redirect_to group_path(@group), notice: "Your project has been removed from #{@group.name}." }
      format.js { render status: :ok, json: @group.to_json }
    end
  end

  def update_certificate
    @collection = ProjectCollection.find params[:id]

    authorize! :update, @collection

    @collection.update_attribute :certified, !@collection.certified?

    flash[:notice] = "Project #{'un' unless @collection.certified?}certified."
    redirect_to group_admin_projects_path(@group, status: params[:status])
  end

  def update_workflow
    @collection = ProjectCollection.find params[:id]

    authorize! :update, @collection

    if params[:event].in? %w(approve reject feature unfeature) and @collection.send "can_#{params[:event]}?"
      @collection.send "#{params[:event]}!"
      flash[:notice] = "Project updated!"
    else
      flash[:alert] = "Couldn't update project, please try again."
    end

    redirect_to group_admin_projects_path(@group, status: params[:status])
  end

  private
    def load_group
      @group = if params[:event_name]
        @event = Event.includes(:hackathon).where(groups: { user_name: params[:event_name] }, hackathons_groups: { user_name: params[:user_name] }).first!
      elsif params[:event_id]
        @event = LiveEvent.find params[:event_id]
      elsif params[:promotion_name]
        load_assignment
      elsif params[:user_name]
        case request.path.split('/')[1]
        when 'communities'
          @community = Community.where(type: 'Community').find_by_user_name! params[:user_name]
        when 'hackerspaces'
          @hacker_space = HackerSpace.find_by_user_name! params[:user_name]
        when 'lists'
          @list = List.find_by_user_name! params[:user_name]
        end
      else
        @group = Group.find params[:group_id]
      end
    end

    def set_layout
      case @group
      when Event
        'group_shared'
      else
        current_layout
      end
    end
end