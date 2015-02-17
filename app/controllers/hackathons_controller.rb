class HackathonsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_hackathon, only: [:show, :update]
  layout 'group_shared', only: [:show]
  respond_to :html

  def show
    title @hackathon.name
    meta_desc "Join the event #{@hackathon.name} on Hackster.io!"

    # @projects = @hackathon.projects.for_thumb_display.paginate(page: safe_page_params)
    @events = @hackathon.events.public.order(start_date: :desc).paginate(page: safe_page_params)
    @event = @hackathon.closest_event

    render "groups/hackathons/show"
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