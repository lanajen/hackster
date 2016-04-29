class LiveChaptersController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_live_chapter, except: [:index]
  respond_to :html

  def index
    unless user_signed_in?
      surrogate_keys = ['live_chapters']
      set_surrogate_key_header *surrogate_keys
      set_cache_control_headers 86400
    end

    @chapters = LiveChapterDecorator.decorate_collection(LiveChapter.order(:virtual, :country, :city))
  end

  def show
    title @live_chapter.name
    meta_desc "Join the event #{@live_chapter.name} on Hackster.io!"

    @upcoming_events = @live_chapter.events.publyc.upcoming.paginate(page: safe_page_params)
    @past_events = @live_chapter.events.publyc.past.paginate(page: safe_page_params)
    @now_events = @live_chapter.events.publyc.now.paginate(page: safe_page_params)
    @organizers = @live_chapter.members.with_group_roles('organizer').order(created_at: :asc).includes(:user)
    @participants = @live_chapter.members.with_group_roles('member').order(created_at: :desc).includes(:user)

    @live_chapter = @live_chapter.decorate

    render "groups/live_chapters/show"
  end

  def update
    authorize! :update, @live_chapter

    if @live_chapter.update_attributes(params[:group])
      redirect_to @live_chapter, notice: 'Profile updated.'

      track_event 'Updated live_chapter'
    else
      @live_chapter.build_avatar unless @live_chapter.avatar
      respond_to do |format|
        format.html { render action: 'edit' }
        format.js { render json: { group: @live_chapter.errors }, status: :unprocessable_entity }
      end
    end
  end

  private
    def load_live_chapter
      @live_chapter = @group = load_with_user_name LiveChapter
      @organizers = @group.members.includes(:user).includes(user: :avatar).invitation_accepted_or_not_invited.with_group_roles('organizer').map(&:user)
    end
end