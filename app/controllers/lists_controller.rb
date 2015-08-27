class ListsController < ApplicationController

  before_filter :authenticate_user!, only: [:edit, :update]
  before_filter :load_list, only: [:show, :update]
  before_filter :load_projects, only: [:show, :embed]
  before_filter :load_project, only: [:feature_project, :unfeature_project]
  layout 'group_shared', only: [:edit, :update, :show]
  after_action :allow_iframe, only: [:embed]
  respond_to :html

  def index
    title "Explore lists"
    meta_desc "Explore hardware projects by topics through curated lists."
    @lists = List.public.order(members_count: :desc)

    render "groups/lists/#{self.action_name}"
  end

  def show
    impressionist_async @list, "", unique: [:session_hash]
    authorize! :read, @list
    title @list.name
    meta_desc "#{@list.mini_resume} Explore #{@list.projects_count} hardware projects in '#{@list.name}'."

    render "groups/shared/#{self.action_name}"

    # track_event 'Visited list', @list.to_tracker.merge({ page: safe_page_params })
  end

  def new
    title "Create a new list"
    meta_desc "Create a list on Hackster and curate thousands of hardware and IoT projects."
    @list = List.new
    authorize! :create, @list
    render 'groups/lists/new'
  end

  def create
    @list = List.new params[:group]
    @list.private = true
    authorize! :create, @list

    if user_signed_in?
      @list.members.new user_id: current_user.id
    else
      @list.require_admin_email = true
    end

    if @list.valid?
      if user_signed_in?
        @list.save
        redirect_to @list, notice: "Welcome to your new list!"
      else
        redirect_to create__simplified_registrations_path(user: { email: @list.admin_email }, redirect_to: create_lists_path(group: params[:group]))
      end
    else
      render 'groups/lists/new'
    end
  end

  def update
    authorize! :update, @list
    old_list = @list.dup

    if @list.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @list, notice: 'Profile updated.' }
        format.js do
          if old_list.user_name != @list.user_name
            @refresh = true
          end
          @list = GroupDecorator.decorate(@list)

          render "groups/lists/#{self.action_name}"
        end

        track_event 'Updated list'
      end
    else
      @list.build_avatar unless @list.avatar
      respond_to do |format|
        format.html { render template: 'groups/shared/edit' }
        format.js { render json: { group: @list.errors }, status: :unprocessable_entity }
      end
    end
  end

  def feature_project
    @group_rel = ProjectCollection.where(project_id: params[:project_id], collectable_id: params[:list_id], collectable_type: 'Group').first!

    if @group_rel.feature!
      respond_to do |format|
        format.html { redirect_to @project, notice: "#{@project.name} has been featured." }
        format.js { render 'groups/lists/button_featured' }
      end
    else
      respond_to do |format|
        format.html { redirect_to @project, alert: "Couldn\'t feature project!" }
        format.js { render text: 'alert("Couldn\'t feature project!")' }
      end
    end
  end

  def unfeature_project
    @group_rel = ProjectCollection.where(project_id: params[:project_id], collectable_id: params[:list_id], collectable_type: 'Group').first!

    if @group_rel.unfeature!
      respond_to do |format|
        format.html { redirect_to @project, notice: "#{@project.name} was unfeatured." }
        format.js { render 'groups/lists/button_featured' }
      end
    end
  end

  private
    def load_projects
      per_page = params[:per_page] ? [Integer(params[:per_page]), Project.per_page].min : Project.per_page

      @projects = if @list.enable_comments
        @list.project_collections.joins(:project).visible.order('project_collections.workflow_state DESC').merge(Project.indexable_and_external.for_thumb_display_in_collection).paginate(page: safe_page_params, per_page: per_page)
      else
        @list.projects.visible.order('project_collections.workflow_state DESC').magic_sort.for_thumb_display.paginate(page: safe_page_params, per_page: per_page)
      end
    end

    def load_list
      @group = @list = List.where("LOWER(groups.user_name) = ?", params[:user_name].downcase).first!
    end
end