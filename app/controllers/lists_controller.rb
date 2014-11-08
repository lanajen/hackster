class ListsController < ApplicationController

  before_filter :authenticate_user!, except: [:show, :embed, :index]
  before_filter :load_list, only: [:show, :update]
  before_filter :load_projects, only: [:show, :embed]
  before_filter :load_project, only: [:feature_project, :unfeature_project]
  layout 'list', only: [:edit, :update, :show]
  after_action :allow_iframe, only: [:embed]
  respond_to :html

  # def index
  #   title "Explore platforms"
  #   meta_desc "Find hardware and software platforms to help you build your next hacks."
  #   @lists = List.public.for_thumb_display.order(:full_name)

  #   render "groups/lists/#{self.action_name}"
  # end

  def show
    impressionist_async @list, "", unique: [:session_hash]
    # authorize! :read, @list
    title "#{@list.name} projects and hacks"
    meta_desc "Discover hacks and projects built with #{@list.name}, and share your own!"

    render "groups/lists/#{self.action_name}"

    # track_event 'Visited list', @list.to_tracker.merge({ page: safe_page_params })
  end

  # def embed
  #   title "Projects built with #{@list.name}"
  #   @list_style = ([params[:list_style]] & ['', '_horizontal']).first || ''
  #   @list_style = '_vertical' if @list_style == ''
  #   render "groups/lists/#{self.action_name}", layout: 'embed'
  # end

  def edit
    @list = List.find params[:id]
    authorize! :update, @list
    @list.build_avatar unless @list.avatar

    render "groups/lists/#{self.action_name}"
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
        format.html { render template: 'groups/lists/edit' }
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
      @projects = @list.projects.visible.indexable_and_external.order('project_collections.workflow_state DESC').magic_sort.for_thumb_display.paginate(page: safe_page_params, per_page: per_page)
    end

    def load_list
      @list = List.where(type: 'List').where("LOWER(groups.user_name) = ?", params[:user_name].downcase).first!
    end
end