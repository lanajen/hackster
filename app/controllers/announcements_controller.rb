class AnnouncementsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_filter :load_tech, except: [:show_redirect, :destroy]
  before_filter :load_announcement, only: [:show]
  before_filter :load_and_authorize_resource, only: [:edit, :update, :destroy]
  layout 'tech'

  def index
    authorize! :read, Announcement
    title "#{@tech.name} - Announcements"
    @announcements = @tech.announcements
    @announcements = @announcements.published unless current_user.try(:can?, :create, Announcement, @tech)
    @announcements = @announcements.order(created_at: :desc).paginate(page: safe_page_params)
  end

  def show
    authorize! :read, @announcement
    @announcement = BlogPostDecorator.decorate(@announcement)
    title "Announcements / #{@announcement.title} | #{@tech.name}"
  end

  def show_redirect
    @announcement = Announcement.find params[:id]
    redirect_to tech_announcement_path @announcement.threadable, @announcement
  end

  def new
    authorize! :create, Announcement, @tech
    @announcement = @tech.announcements.new
    @announcement.user_id = current_user.id
    @announcement.save validate: false
    redirect_to edit_tech_announcement_path(@tech.user_name, @announcement.id)
  end

  def create
    authorize! :create, Announcement, @tech
    @announcement = @tech.announcements.new(params[:announcement])
    @announcement.user = current_user

    if @announcement.save
      redirect_to tech_announcement_path(@announcement), notice: 'Announcement created.'
    else
      render 'new'
    end
  end

  def edit
    @announcement = BlogPostDecorator.decorate(@announcement)
    title "Announcements / Edit #{@announcement.title} | #{@tech.name}"
  end

  def update
    if @announcement.update_attributes(params[:announcement])
      redirect_to tech_announcement_path(@announcement), notice: 'Announcement updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @tech = @announcement.threadable
    @announcement.destroy

    redirect_to tech_announcements_path(@tech.user_name), notice: "\"#{@announcement.title}\" was deleted."
  end

  private
    def load_announcement
      @announcement = @tech.announcements.where(sub_id: params[:id]).first!
    end

    def load_and_authorize_resource
      @announcement = Announcement.find params[:id]
      # load_announcement
      authorize! self.action_name.to_sym, @announcement
    end

    def load_tech
      @tech = load_with_slug
    end
end