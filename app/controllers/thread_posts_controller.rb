class ThreadPostsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
#  load_and_authorize_resource
  load_resource
  skip_authorize_resource only: [:redirect_to_show]
  skip_load_resource only: [:new, :create]
  before_filter :find_project, except: [:redirect_to_show]
  layout 'project'
  respond_to :html
  helper_method :index_url_for
  before_filter :get_type

  def index
    @thread_posts = @type.classify.constantize.where(threadable_id: params[:project_id],
      threadable_type: 'Project')
    render "#{@type}/index"
  end

  def show
    render "#{@type}/show"
  end

  def new
    @thread_post = @type.classify.constantize.new
    render "#{@type}/new"
  end

  def edit
    render "#{@type}/edit"
  end

  def create
    @thread_post = @type.classify.constantize.new
    @thread_post.assign_attributes(params[@thread_post.class.to_s.underscore])
    @thread_post.threadable = @project
    @thread_post.user = current_user

    if @thread_post.save
      flash[:notice] = "#{@thread_post.type.humanize} was successfully created."
      respond_with [@thread_post.threadable, @thread_post]
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

  private
    def find_project
      @project = Project.find params[:project_id]
    end

    def get_type
      @type = request.path.split(/\//)[3]
    end

    def index_url_for thread
      case thread
      when BlogPost
        project_blog_posts_url(@project)
      when Discussion
        project_discussions_url(@project)
      end
    end
end