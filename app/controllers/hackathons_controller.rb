class HackathonsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_hackathon
  layout 'group_shared', except: [:update]
  respond_to :html

  def show
    title @hackathon.name
    meta_desc "Join the event #{@hackathon.name} on Hackster.io!"

    # @projects = @hackathon.projects.for_thumb_display.paginate(page: safe_page_params)
    @upcoming_events = if can? :manage, @hackathon
      @hackathon.events
    else
      @hackathon.events.publyc
    end
    @upcoming_events = @upcoming_events.upcoming.paginate(page: safe_page_params)
    @past_events = @hackathon.events.publyc.past.paginate(page: safe_page_params)
    @now_events = @hackathon.events.publyc.now.paginate(page: safe_page_params)
    @event = @hackathon.closest_event

    render "groups/hackathons/show"
  end

  def edit_schedule
    render "groups/shared/edit_schedule"
  end

  def organizers
    @organizers = @group.members.includes(:user).includes(user: :avatar).invitation_accepted_or_not_invited.with_group_roles('organizer').map(&:user)

    render "groups/events/organizers"
  end

  def update
    authorize! :update, @hackathon
    old_hackathon = @hackathon.dup

    if @hackathon.update_attributes(params[:group])
      respond_to do |format|
        format.html { redirect_to @hackathon, notice: 'Profile updated.' }
        format.js do
          @hackathon = @hackathon.decorate
          if old_hackathon.user_name != @hackathon.user_name
            @refresh = true
          end

          render "groups/hackathons/#{self.action_name}"
        end

        track_event 'Updated hackathon'
      end
    else
      @hackathon.build_avatar unless @hackathon.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: { group: @hackathon.errors }, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_hackathon
      @hackathon = @group = load_with_user_name Hackathon
    end
end