class LiveEventsController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :edit, :update]
  before_filter :load_live_event, except: [:new, :create]
  before_filter :load_live_chapter, only: [:new, :create]
  layout 'group_shared', except: [:embed, :new, :create, :update]
  after_action :allow_iframe, only: :embed
  respond_to :html

  def show
    redirect_to (@event.in_the_future? ? live_event_info_path(@event) : live_event_projects_path(@event))
  end

  def info
    title @event.name
    meta_desc "Join the event #{@event.name} on Hackster.io!"

    @group = @event = LiveEventDecorator.decorate(@event)

    render "groups/live_events/info"
  end

  def projects
    title @event.name
    meta_desc "See what's cooking at #{@event.name}."

    @projects = @event.project_collections.visible.includes(:project).visible.merge(BaseArticle.for_thumb_display_in_collection.order('projects.respects_count DESC')).paginate(page: safe_page_params)

    render "groups/live_events/projects"
  end

  def embed
    @list_style = ([params[:list_style]] & ['', '_horizontal']).first || ''
    # @list_style = '_horizontal'
    @projects = @event.projects.publyc.order('projects.respects_count DESC')
    render "groups/live_events/#{self.action_name}", layout: 'embed'
  end

  def new
    authorize! :create, LiveEvent
    title "Create a new event"
    @event = LiveEvent.new

    render "groups/live_events/#{self.action_name}"
  end

  def create
    @event = @live_chapter.events.new(params[:group])
    authorize! :create, @event

    admin = @event.members.new(user_id: current_user.id, group_roles: ['organizer'])

    if @event.save

      admin.update_attribute :permission_action, 'manage'
      flash[:notice] = "Welcome to #{@event.class.name} #{@event.name}!"
      respond_with @event
    else
      render "groups/live_events/new"
    end
  end

  def update
    authorize! :update, @event
    old_event = @event.dup

    if @event.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @event, notice: 'Profile updated.' }

        track_event 'Updated event'
      end
    else
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: { group: @event.errors }, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_live_chapter
      @live_chapter = load_with_user_name LiveChapter
    end

    def load_live_event
      @group = @event = LiveEvent.find params[:event_id] || params[:id]
    end
end