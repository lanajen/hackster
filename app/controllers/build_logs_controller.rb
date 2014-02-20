class BuildLogsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_project
  before_filter :load_log, only: [:show, :edit, :update, :destroy]
  before_filter :set_project_mode
  layout 'project'

  def index
    title "Logs for #{@project.name}"
    @logs = @project.blog_posts.order(created_at: :desc)
    authorize! :read, @project.blog_posts.new
  end

  def show
    title "Logs > #{@log.title} | #{@project.name}"
  end

  def new
    title "New log | #{@project.name}"
    @log = @project.blog_posts.new
  end

  def create
    @log = @project.blog_posts.new(params[:blog_post])
    @log.user = current_user

    if @log.save
      redirect_to project_log_path(@project.user_name_for_url, @project.slug, @log.sub_id), notice: 'Log created.'
    else
      render 'new'
    end
  end

  def edit
    title "Logs > Edit #{@log.title} | #{@project.name}"
  end

  def update
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