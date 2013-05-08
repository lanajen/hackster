class ThreadPostsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource except: [:index, :new, :create]
#  load_resource
  skip_authorize_resource only: [:redirect_to_show]
  before_filter :find_threadable, except: [:redirect_to_show, :update_workflow]
  before_filter :find_project, except: [:redirect_to_show, :update_workflow]
  layout 'project'
  respond_to :html
  helper_method :index_url_for
  before_filter :get_type

  def index
    authorize! :read, @project
    @thread_posts = Issue

    @thread_posts = if params[:threadable]
      @thread_posts.where(threadable_type: params[:threadable_type].classify, threadable_id: params[:threadable])
    else
      (@project.issues + @thread_posts.where(threadable_type: 'Widget').where('threadable_id IN (?)', @project.widgets.pluck('widgets.id'))).sort_by{ |t| t.created_at }.reverse
    end

    if params[:status]
      @thread_posts = @thread_posts.where(workflow_state: params[:status])
    end

    render "#{@type}/index"
  end

  def show
    render "#{@type}/show"
  end

  def new
    @thread_post = @type.classify.constantize.new
    @thread_post.threadable = @threadable
    authorize! :new, @thread_post
    render "#{@type}/new"
  end

  def edit
    render "#{@type}/edit"
  end

  def create
    @thread_post = @type.classify.constantize.new
    @thread_post.threadable = @threadable
    authorize! :new, @thread_post

    @thread_post.assign_attributes(params[@thread_post.class.to_s.underscore])
    @thread_post.user = current_user

    if @thread_post.save
      flash[:notice] = "#{@thread_post.type.humanize} was successfully created."
      respond_with [@threadable, @thread_post]
    else
      render action: 'new', template: "#{@type}/new"
    end
  end

  def update
    if @thread_post.update_attributes(params[@thread_post.class.to_s.underscore])
      flash[:notice] = "#{@thread_post.class.to_s.humanize} was successfully updated."
      respond_with [@thread_post.threadable, @thread_post]
    else
      render action: 'edit', template: "#{@type}/edit"
    end
  end

  def destroy
    @thread_post.destroy

    redirect_to index_url_for(@thread_post)
  end

  def redirect_to_show
    redirect_to index_url_for(@thread_post)
  end

  def update_workflow
    @thread_post.send "#{params[:event]}!"

    redirect_to params[:redirect_to], notice: "Update successful!"
  end

  private
    def find_project
      @project ||= @threadable.project
    end

    def find_threadable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          @threadable = $1.classify.constantize.find(value)
          instance_variable_set(:"@#{@threadable.class.name.underscore}", @threadable)
          return
        end
      end
    end

    def get_type
      @type = request.path.split(/\//)[3]
    end

    def index_url_for thread
      url_for [thread.threadable, thread.class.name.underscore.to_sym]
    end
end