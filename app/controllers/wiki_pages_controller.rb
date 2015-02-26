class WikiPagesController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_filter :load_group, except: [:destroy]
  before_filter :load_page, only: [:edit, :update, :destroy]
  before_filter :load_page_with_slug, only: :show
  layout 'group_shared'

  # def index
  #   authorize! :read, Page, @group
  #   title "Pages for #{@group.name}"
  #   @pages = @group.pages.order(created_at: :desc).where(type: 'Page')
  #   params[:status] ||= 'open'
  #   @pages = @pages.where(workflow_state: params[:status]) if params[:status].in? %w(open closed)
  # end

  def show
    authorize! :read, @page
    title "Pages / #{@page.title} | #{@group.name}"
  end

  def new
    authorize! :create, Page, @group
    title "New page | #{@group.name}"
    @page = @group.pages.new
  end

  def create
    @page = @group.pages.new(params[:page])
    authorize! :create, @page
    @page.user = current_user

    if @page.save
      redirect_to group_page_path(@group, @page), notice: 'Page created.'
    else
      render 'new'
    end
  end

  def edit
    authorize! :edit, @page
    title "Pages / Edit #{@page.title} | #{@group.name}"
  end

  def update
    authorize! :edit, @page
    if @page.update_attributes(params[:page])
      redirect_to group_page_path(@group, @page), notice: 'Page updated.'
    else
      render 'edit'
    end
  end

  def destroy
    authorize! :destroy, @page
    @group = @page.threadable
    @page.destroy

    redirect_to event_path(@group), notice: 'Page destroyed'
  end

  private
    def load_group
      @group = if params[:event_name]
        load_event
      else
        load_with_user_name Hackathon
      end
    end

    def load_page_with_slug
      @page = @group.pages.where(slug: params[:slug]).first!
    end

    def load_page
      @page = Page.find params[:id]
    end
end