class BuildLogsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_filter :load_project, except: [:destroy, :show_redirect]
  before_filter :load_log, only: [:show]
  before_filter :load_and_authorize_resource, only: [:edit, :update, :destroy]
  before_filter :set_project_mode, except: [:destroy, :show_redirect]
  layout 'project'

  def index
    authorize! :read, @project.blog_posts.new
    title "Logs for #{@project.name}"
    @logs = @project.blog_posts
    @logs = @logs.published unless current_user.try(:can?, :create, BlogPost, @project)
    @logs = @logs.order(created_at: :desc).paginate(page: params[:page])
  end

  def show
    authorize! :read, @log
    @log = @log.decorate
    title "Logs / #{@log.title} | #{@project.name}"
  end

  def show_redirect
    @log = BlogPost.find params[:id]
    redirect_to log_path @log.threadable, @log
  end

  def new
    authorize! :create, BlogPost, @project
    title "New log | #{@project.name}"
    @log = @project.blog_posts.new
    @log.user_id = current_user.id
    @log.save validate: false
    redirect_to edit_project_log_path(@project.user_name_for_url, @project.slug, @log.id)
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
    @log = @log.decorate
    title "Logs / Edit #{@log.title} | #{@project.name}"
  end

  def update
    if @log.update_attributes(params[:blog_post])
      redirect_to project_log_path(@project.user_name_for_url, @project.slug, @log.sub_id), notice: 'Log updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @project = @log.threadable
    @log.destroy

    redirect_to project_logs_path(@project.user_name_for_url, @project.slug), notice: "\"#{@log.title}\" was deleted."
  end

  private
    def load_log
      @log = @project.blog_posts.where(sub_id: params[:id]).first!
    end

    def load_and_authorize_resource
      @log = BlogPost.find params[:id]
      authorize! self.action_name.to_sym, @log
    end
end