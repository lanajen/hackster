class AnnouncementsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_filter :load_platform, except: [:show_redirect, :destroy]
  before_filter :load_announcement, only: [:show]
  before_filter :load_and_authorize_resource, only: [:edit, :update, :destroy]
  layout 'platform'

  def index
    authorize! :read, Announcement
    title "#{@platform.name} - Announcements"
    @announcements = @platform.announcements
    @announcements = @announcements.published unless current_user.try(:can?, :create, Announcement, @platform)
    @announcements = @announcements.order(created_at: :desc).paginate(page: safe_page_params)
  end

  def show
    authorize! :read, @announcement
    @announcement = BuildLogDecorator.decorate(@announcement)
    title "Announcements / #{@announcement.title} | #{@platform.name}"
  end

  def show_redirect
    @announcement = Announcement.find params[:id]
    redirect_to platform_announcement_path @announcement.threadable, @announcement
  end

  def new
    authorize! :create, Announcement, @platform
    @announcement = @platform.announcements.new
    @announcement.user_id = current_user.id
    @announcement.draft = true
    @announcement.save validate: false
    redirect_to edit_platform_announcement_path(@platform.user_name, @announcement.id)
  end

  def create
    authorize! :create, Announcement, @platform
    @announcement = @platform.announcements.new(params[:announcement])
    @announcement.user = current_user

    if @announcement.save
      redirect_to platform_announcement_path(@announcement), notice: 'Announcement created.'
    else
      render 'new'
    end
  end

  def edit
    @announcement = BuildLogDecorator.decorate(@announcement)
    title "Announcements / Edit #{@announcement.title} | #{@platform.name}"
  end

  def update
    if @announcement.update_attributes(params[:announcement])
      redirect_to platform_announcement_path(@announcement), notice: 'Announcement updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @platform = @announcement.threadable
    @announcement.destroy

    redirect_to platform_announcements_path(@platform.user_name), notice: "\"#{@announcement.title}\" was deleted."
  end

  private
    def load_announcement
      @announcement = @platform.announcements.where(sub_id: params[:id]).first!
    end

    def load_and_authorize_resource
      @announcement = Announcement.find params[:id]
      # load_announcement
      authorize! self.action_name.to_sym, @announcement
    end

    def load_platform
      @group = @platform = load_with_slug
    end
end