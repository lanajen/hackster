class MeetupsController < MainBaseController
  before_filter :authenticate_user!, only: [:new, :create, :update]
  before_filter :load_meetup, only: [:show, :update]
  respond_to :html

  def index
    unless user_signed_in?
      surrogate_keys = ['meetups']
      set_surrogate_key_header *surrogate_keys
      set_cache_control_headers 86400
    end

    title "Hackster Live Events"
    meta_desc "Join Hackster Live events near you to meet hardware enthusiasts and learn about new technology."

    @chapters = MeetupDecorator.decorate_collection(LiveChapter.order(:country, :city))
  end

  def show
    title @meetup.name
    meta_desc "Join the event #{@meetup.name} on Hackster.io!"

    if user_signed_in? and current_user.can? :manage, @meetup
      @draft_events = @meetup.events.pryvate#.paginate(page: safe_page_params)
    end
    @upcoming_events = @meetup.events.publyc.upcoming#.paginate(page: safe_page_params)
    @past_events = @meetup.events.publyc.past#.paginate(page: safe_page_params)
    @now_events = @meetup.events.publyc.now#.paginate(page: safe_page_params)
    @organizers = @meetup.members.with_group_roles('organizer').order(created_at: :asc).includes(:user)
    @participants = @meetup.members.with_group_roles('member').order(created_at: :desc).invitation_accepted_or_not_invited.includes(:user)

    @meetup = @meetup.decorate

    render "groups/meetups/show"
  end

  def new
    @meetup = Meetup.new

    render "groups/meetups/new"
  end

  def create
    @meetup = Meetup.new params[:group]

    @meetup.members.new(user_id: current_user.id, group_roles: ['organizer'])

    if @meetup.save
      redirect_to @meetup, notice: "Your meetup page was created!"
    else
      render "groups/meetups/new"
    end
  end

  def update
    authorize! :update, @meetup

    if @meetup.update_attributes(params[:group])
      redirect_to @meetup, notice: 'Meetup updated.'
    else
      @meetup.build_avatar unless @meetup.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: { group: @meetup.errors }, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_meetup
      @meetup = @group = Group.where(type: %w(Meetup LiveChapter)).where("LOWER(groups.user_name) = ?", params[:user_name].downcase).first!
      @organizers = @group.members.includes(:user).includes(user: :avatar).invitation_accepted_or_not_invited.with_group_roles('organizer').map(&:user)
    end
end