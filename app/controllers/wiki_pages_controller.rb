class WikiPagesController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_filter :load_event, except: [:destroy]
  before_filter :load_page, only: [:edit, :update, :destroy]
  before_filter :load_page_with_slug, only: :show
  layout 'event'

  # def index
  #   authorize! :read, Page, @event
  #   title "Pages for #{@event.name}"
  #   @pages = @event.pages.order(created_at: :desc).where(type: 'Page')
  #   params[:status] ||= 'open'
  #   @pages = @pages.where(workflow_state: params[:status]) if params[:status].in? %w(open closed)
  # end

  def show
    authorize! :read, @page
    title "Pages / #{@page.title} | #{@event.name}"
  end

  def new
    authorize! :create, Page, @event
    title "New page | #{@event.name}"
    @page = @event.pages.new
  end

  def create
    @page = @event.pages.new(params[:page])
    authorize! :create, @page
    @page.user = current_user

    if @page.save
      redirect_to hackathon_event_page_path(@event.hackathon.user_name, @event.user_name, @page.slug), notice: 'Page created.'
    else
      render 'new'
    end
  end

  def edit
    authorize! :edit, @page
    title "Pages / Edit #{@page.title} | #{@event.name}"
  end

  def update
    authorize! :edit, @page
    if @page.update_attributes(params[:page])
      redirect_to hackathon_event_page_path(@event.hackathon.user_name, @event.user_name, @page.slug), notice: 'Page updated.'
    else
      render 'edit'
    end
  end

  def destroy
    authorize! :destroy, @page
    @event = @page.threadable
    @page.destroy

    redirect_to event_path(@event), notice: 'Page destroyed'
  end

  private
    def load_page_with_slug
      @page = @event.pages.where(slug: params[:slug]).first!
    end

    def load_page
      @page = Page.find params[:id]
    end
end