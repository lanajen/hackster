class Admin::BlogPostsController < Admin::BaseController
  def index
    title "Admin / Blog Posts - #{safe_page_params}"
    @fields = {
      'created_at' => 'threads.created_at',
      'title' => 'threads.title',
    }

    params[:sort_by] ||= 'created_at'

    @posts = filter_for HacksterBlogPost, @fields
  end

  def new
    @post = HacksterBlogPost.new private: true
  end

  def create
    @post = HacksterBlogPost.new(params[:hackster_blog_post])
    @post.user = current_user

    if @post.save
      redirect_to admin_blog_posts_path, :notice => 'New post created'
    else
      render :new
    end
  end

  def edit
    @post = HacksterBlogPost.find(params[:id])
  end

  def update
    @post = HacksterBlogPost.find(params[:id])

    if @post.update_attributes(params[:hackster_blog_post])
      redirect_to admin_blog_posts_path, :notice => 'Blog post successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @post = HacksterBlogPost.find(params[:id])
    @post.destroy
    redirect_to admin_blog_posts_path, :notice => 'Blog post successfuly deleted'
  end
end