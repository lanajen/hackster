class MeetupEventsController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :edit, :update]
  before_filter :load_meetup_event, except: [:new, :create]
  before_filter :load_meetup, only: [:new, :create]
  after_action :allow_iframe, only: :embed
  respond_to :html

  def show
    title @event.name
    meta_desc "Join the event #{@event.name} on Hackster.io!"

    @group = @event = MeetupEventDecorator.decorate(@event)
    @going = (user_signed_in? and current_user.is_member? @event)
    @organizers = @event.members.with_group_roles('organizer').order(:created_at).includes(:user)
    @participants = @event.members.with_group_roles('participant').order(:created_at).includes(:user)
    @projects = @event.project_collections.visible.includes(:project).visible.merge(BaseArticle.for_thumb_display_in_collection.order('projects.respects_count DESC')).paginate(page: safe_page_params)

    render "groups/meetup_events/show"
  end

  def embed
    @list_style = ([params[:list_style]] & ['', '_horizontal']).first || ''
    # @list_style = '_horizontal'
    @projects = @event.projects.publyc.order('projects.respects_count DESC')
    render "groups/meetup_events/#{self.action_name}", layout: 'embed'
  end

  def new
    authorize! :create, MeetupEvent
    title "Create a new event"
    @event = MeetupEvent.new

    render "groups/meetup_events/#{self.action_name}"
  end

  def create
    @event = @meetup.events.new(params[:group])
    authorize! :create, @event

    admin = @event.members.new(user_id: current_user.id, group_roles: ['organizer'])

    if @event.save

      admin.update_attribute :permission_action, 'manage'
      flash[:notice] = "Welcome to #{@event.class.name} #{@event.name}!"
      respond_with @event
    else
      render "groups/meetup_events/new"
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
    def load_meetup
      @meetup = load_with_user_name Meetup
    end

    def load_meetup_event
      @group = @event = MeetupEvent.find params[:event_id] || params[:id]
    end
end