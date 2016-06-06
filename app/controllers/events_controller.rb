class EventsController < MainBaseController
  before_filter :authenticate_user!, only: [:new, :create, :edit, :update, :participants_list]
  before_filter :load_event, except: [:new, :create, :export]
  before_filter :load_hackathon, only: [:new, :create]
  layout 'group_shared', except: [:embed, :new, :create, :update, :export]
  after_action :allow_iframe, only: :embed
  respond_to :html

  def show
    redirect_to (@event.in_the_future? ? event_info_path(@event) : event_projects_path(@event))
  end

  def export
    event = Group.find(params[:id])  # using group so it works for both Event and MeetupEvent
    @event = "#{event.class.name}Decorator".constantize.decorate event

    out = render_to_string 'export.ics'

    send_data out,
      filename: 'event.ics',
      type: 'text/calendar',
      disposition: 'attachment'
  end

  def info
    title @event.name
    meta_desc "Join the event #{@event.name} on Hackster.io!"

    @group = @event = EventDecorator.decorate(@event)

    render "groups/events/info"
  end

  def participants_list
    authorize! :manage, @event

    @projects = @event.project_collections.visible.includes(:project).visible.merge(BaseArticle.for_thumb_display_in_collection.order('projects.respects_count DESC')).paginate(page: safe_page_params)

    render "groups/events/participants_list"
  end

  def projects
    title @event.name
    meta_desc "See what's cooking at #{@event.name}."

    @projects = @event.project_collections.visible.includes(:project).visible.merge(BaseArticle.for_thumb_display_in_collection.order('projects.respects_count DESC')).paginate(page: safe_page_params)
    @awards = @event.awards

    render "groups/events/projects"
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
    @projects = @event.projects.publyc.order('projects.respects_count DESC')
    render "groups/events/#{self.action_name}", layout: 'embed'
  end

  def edit_schedule
    render "groups/shared/edit_schedule"
  end

  def new
    authorize! :create, Event
    title "Create a new event"
    @event = Event.new

    render "groups/events/#{self.action_name}"
  end

  def create
    @event = @hackathon.events.new(params[:group])
    authorize! :create, @event

    admin = @event.members.new(user_id: current_user.id, group_roles: ['organizer'])
    @event.pryvate = true

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

  private
    def load_hackathon
      @hackathon = load_with_user_name Hackathon
    end
end