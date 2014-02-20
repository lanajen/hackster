class BuildLogsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_filter :load_project
  before_filter :load_log, only: [:show, :edit, :update, :destroy]
  before_filter :set_project_mode
  layout 'project'

  def index
    authorize! :read, @project.blog_posts.new
    title "Logs for #{@project.name}"
    @logs = @project.blog_posts.order(created_at: :desc)
  end

  def show
    authorize! :read, @log
    title "Logs > #{@log.title} | #{@project.name}"
  end

  def new
    authorize! :create, BlogPost, @project
    title "New log | #{@project.name}"
    @log = @project.blog_posts.new
  end

  def create
    authorize! :create, BlogPost, @project
    @log = @project.blog_posts.new(params[:blog_post])
    @log.user = current_user

    if @log.save
      redirect_to project_log_path(@project.user_name_for_url, @project.slug, @log.sub_id), notice: 'Log created.'
    else
      render 'new'
    end
  end

  def edit
    authorize! :edit, @log
    title "Logs > Edit #{@log.title} | #{@project.name}"
  end

  def update
    authorize! :edit, @log
    if @log.update_attributes(params[:blog_post])
      redirect_to project_log_path(@project.user_name_for_url, @project.slug, @log.sub_id), notice: 'Log updated.'
    else
      render 'edit'
    end
  end

  private
    def load_log
      @log = @project.blog_posts.where(sub_id: params[:id]).first!
    end
end