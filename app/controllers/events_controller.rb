class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :participants, :organizers, :embed]
  before_filter :load_event, only: [:show, :update, :participants, :organizers, :embed]
  layout 'group_shared', only: [:edit, :update, :show, :participants, :organizers]
  after_action :allow_iframe, only: :embed
  respond_to :html

  def show
    title @event.name
    meta_desc "Join the event #{@event.name} on Hackster.io!"

    @projects = @event.project_collections.visible.includes(:project).visible.merge(Project.for_thumb_display_in_collection.order('projects.respects_count DESC')).paginate(page: safe_page_params)
    # @participants = @event.members.request_accepted_or_not_requested.invitation_accepted_or_not_invited.with_group_roles('participant').includes(:user).includes(user: :avatar).map(&:user)
    # @organizers = @event.members.invitation_accepted_or_not_invited.with_group_roles('organizer').includes(:user).includes(user: :avatar).map(&:user)
    @awards = @event.awards

    render "groups/shared/#{self.action_name}"
  end

  def participants
    @participants = @event.members.includes(:user).includes(user: :avatar).request_accepted_or_not_requested.invitation_accepted_or_not_invited.with_group_roles('participant').map(&:user)

    render "groups/events/#{self.action_name}"
  end

  def organizers
    @organizers = @event.members.includes(:user).includes(user: :avatar).invitation_accepted_or_not_invited.with_group_roles('organizer').map(&:user)
    @judges = @event.members.includes(:user).includes(user: :avatar).invitation_accepted_or_not_invited.with_group_roles('judge').map(&:user)
    @mentors = @event.members.includes(:user).includes(user: :avatar).invitation_accepted_or_not_invited.with_group_roles('mentor').map(&:user)

    render "groups/events/#{self.action_name}"
  end

  def embed
    @list_style = ([params[:list_style]] & ['', '_horizontal']).first || ''
    # @list_style = '_horizontal'
    @projects = @event.projects.public.order('projects.respects_count DESC')
    render "groups/events/#{self.action_name}", layout: 'embed'
  end

  def new
    authorize! :create, Event
    title "Create a new event"
    @event = Event.new

    render "groups/events/#{self.action_name}"
  end

  def create
    @event = Event.new(params[:event])
    authorize! :create, @event

    admin = @event.members.new(user_id: current_user.id)
    @event.private = true

    if @event.save
      admin.update_attribute :permission_action, 'manage'
      flash[:notice] = "Welcome to #{@event.class.name} #{@event.name}!"
      respond_with @event
    else
      render "groups/events/new"
    end
  end

  def update
    authorize! :update, @event
    old_event = @event.dup

    if @event.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @event, notice: 'Profile updated.' }
        format.js do
          @event = @event.decorate
          if old_event.user_name != @event.user_name
            @refresh = true
          end

          render "groups/events/#{self.action_name}"
        end

        track_event 'Updated event'
      end
    else
      @event.build_avatar unless @event.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: { group: @event.errors }, status: :unprocessable_entity }
      end
    end
  end
end