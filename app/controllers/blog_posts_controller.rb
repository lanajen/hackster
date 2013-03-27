class BlogPostsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource
  skip_authorize_resource only: [:redirect_to_show]
  skip_load_resource only: [:new, :create]
  before_filter :find_project, except: [:redirect_to_show]
  layout 'project'

  # GET /blog_posts
  # GET /blog_posts.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @blog_posts }
    end
  end

  # GET /blog_posts/1
  # GET /blog_posts/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @blog_post }
    end
  end

  # GET /blog_posts/new
  # GET /blog_posts/new.json
  def new
    @blog_post = @project.blog_posts.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @blog_post }
    end
  end

  # GET /blog_posts/1/edit
  def edit
  end

  # POST /blog_posts
  # POST /blog_posts.json
  def create
    @blog_post = @project.blog_posts.new(params[:blog_post])
    @blog_post.user = current_user

    respond_to do |format|
      if @blog_post.save
        format.html { redirect_to @blog_post, notice: 'Blog post was successfully created.' }
        format.json { render json: @blog_post, status: :created, location: @blog_post }
      else
        format.html { render action: "new" }
        format.json { render json: @blog_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /blog_posts/1
  # PUT /blog_posts/1.json
  def update
    respond_to do |format|
      if @blog_post.update_attributes(params[:blog_post])
        format.html { redirect_to @blog_post, notice: 'Blog post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @blog_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blog_posts/1
  # DELETE /blog_posts/1.json
  def destroy
    @blog_post.destroy

    respond_to do |format|
      format.html { redirect_to project_blog_index_url(@project) }
      format.json { head :no_content }
    end
  end

  def redirect_to_show
    redirect_to project_blog_url(@blog_post.bloggable, @blog_post)
  end

  private
    def find_project
      @project = Project.find params[:project_id]
    end
end