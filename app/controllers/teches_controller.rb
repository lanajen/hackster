class TechesController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :embed, :index]
  before_filter :load_tech, except: [:show, :embed, :index]
  before_filter :load_tech_with_slug, only: [:show, :embed]
  before_filter :load_projects, only: [:show, :embed]
  before_filter :load_project, only: [:feature_project, :unfeature_project]
  layout 'tech', only: [:edit, :update, :show]
  after_action :allow_iframe, only: :embed
  respond_to :html

  def index
    title "Explore tools"
    meta_desc "Find tools for your next hacks on Hackster.io."
    @teches = Tech.public.for_thumb_display.order(:full_name)

    render "groups/teches/#{self.action_name}"
  end

  def show
    impressionist_async @tech, "", unique: [:session_hash]
    # authorize! :read, @tech
    title "#{@tech.name} projects"
    meta_desc "People are hacking with #{@tech.name} on Hackster.io. Join them!"

    render "groups/teches/#{self.action_name}"

    track_event 'Visited tech', @tech.to_tracker.merge({ page: safe_page_params })
  end

  def embed
    title "Projects made with #{@tech.name}"
    @list_style = ([params[:list_style]] & ['', '_horizontal']).first || ''
    @list_style = '_vertical' if @list_style == ''
    render "groups/teches/#{self.action_name}", layout: 'embed'
  end

  def edit
    authorize! :update, @tech
    @tech.build_avatar unless @tech.avatar

    render "groups/teches/#{self.action_name}"
  end

  def update
    authorize! :update, @tech
    old_tech = @tech.dup

    if @tech.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @tech, notice: 'Profile updated.' }
        format.js do
          @tech.avatar = nil unless @tech.avatar.try(:file_url)
          # if old_group.interest_tags_string != @tech.interest_tags_string or old_group.skill_tags_string != @tech.skill_tags_string
          if old_tech.user_name != @tech.user_name
            @refresh = true
          end
          @tech = GroupDecorator.decorate(@tech)

          render "groups/teches/#{self.action_name}"
        end

        track_event 'Updated tech'
      end
    else
      @tech.build_avatar unless @tech.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: { group: @tech.errors }, status: :unprocessable_entity }
      end
    end
  end

  def feature_project
    @group_rel = GroupRelation.where(project_id: params[:project_id], group_id: params[:tech_id]).first!

    if @group_rel.feature!
      respond_to do |format|
        format.html { redirect_to @project, notice: "#{@project.name} has been featured." }
        format.js { render 'groups/teches/button_featured' }
      end
      event_name = 'Respected project'
    else
      respond_to do |format|
        format.html { redirect_to @project, alert: "Couldn\'t feature project!" }
        format.js { render text: 'alert("Couldn\'t feature project!")' }
      end
      event_name = 'Tried respecting own project'
    end
  end

  def unfeature_project
    @group_rel = GroupRelation.where(project_id: params[:project_id], group_id: params[:tech_id]).first!

    if @group_rel.unfeature!
      respond_to do |format|
        format.html { redirect_to @project, notice: "#{@project.name} was unfeatured." }
        format.js { render 'groups/teches/button_featured' }
      end
    end
  end

  private
    def load_projects
      @projects = @tech.projects.visible.indexable_and_external.order('group_relations.workflow_state DESC').magic_sort.for_thumb_display.paginate(page: safe_page_params)
    end

    def load_tech
      @tech = Tech.find(params[:tech_id] || params[:id])
    end

    def load_tech_with_slug
      @tech = load_with_slug
    end
end