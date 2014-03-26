class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_event, only: [:show, :update, :participants, :organizers]
  layout 'event', only: [:edit, :update, :show, :participants, :organizers]
  respond_to :html

  def show
    title @event.name
    meta_desc "Join the event #{@event.name} on Hackster.io!"
    # @broadcasts = @event.broadcasts.limit 20
    @projects = @event.projects.order('projects.respects_count DESC')
    @participants = @event.members.request_accepted_or_not_requested.invitation_accepted_or_not_invited.with_group_roles('participant').map(&:user).select{|u| u.invitation_token.nil? }
    @organizers = @event.members.invitation_accepted_or_not_invited.with_group_roles('organizer').map(&:user).select{|u| u.invitation_token.nil? }

    render "groups/events/#{self.action_name}"
  end

  def participants
    @participants = @event.members.request_accepted_or_not_requested.invitation_accepted_or_not_invited.with_group_roles('participant').map(&:user).select{|u| u.invitation_token.nil? }

    render "groups/events/#{self.action_name}"
  end

  def organizers
    @organizers = @event.members.invitation_accepted_or_not_invited.with_group_roles('organizer').map(&:user).select{|u| u.invitation_token.nil? }

    render "groups/events/#{self.action_name}"
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

  def edit
    @event = Event.find(params[:id])
    authorize! :update, @event
    @event.build_avatar unless @event.avatar

    render "groups/events/#{self.action_name}"
  end

  def update
    authorize! :update, @event
    old_event = @event.dup

    if @event.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @event, notice: 'Profile updated.' }
        format.js do
          @event.avatar = nil unless @event.avatar.try(:file_url)
          @event = @event.decorate
          # if old_event.interest_tags_string != @event.interest_tags_string or old_event.skill_tags_string != @event.skill_tags_string
          #   @refresh = true
          # end

          render "groups/events/#{self.action_name}"
        end

        track_event 'Updated event'
      end
    else
      @event.build_avatar unless @event.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end
end