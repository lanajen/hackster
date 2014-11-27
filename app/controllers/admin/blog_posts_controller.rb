class Admin::BlogPostsController < Admin::BaseController
  def index
    title "Admin / Blog Posts - #{safe_page_params}"
    @fields = {
      'created_at' => 'threads.created_at',
      'title' => 'threads.title',
    }

    params[:sort_by] ||= 'created_at'

    @posts = filter_for BlogPost, @fields
  end

  def new
    @post = BlogPost.new private: true
  end

  def create
    @post = BlogPost.new(params[:blog_post])
    @post.user = current_user

    if @post.save
      redirect_to next_url, :notice => 'New post created'
    else
      render :new
    end
  end

  def edit
    @post = BlogPost.find(params[:id])
  end

  def update
    @post = BlogPost.find(params[:id])

    if @post.update_attributes(params[:blog_post])
      redirect_to next_url, :notice => 'Blog post successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @post = BlogPost.find(params[:id])
    @post.destroy
    redirect_to admin_blog_posts_path, :notice => 'Blog post successfuly deleted'
  end

  private
    def next_url
      next_url = if params[:preview]
        blog_post_path(@post.slug)
      else
        edit_admin_blog_post_path(@post)
      end
    end
end