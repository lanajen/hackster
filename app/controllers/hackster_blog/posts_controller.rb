class HacksterBlog::PostsController < ApplicationController
  layout 'blog'

  def index
    @page = safe_page_params.nil? ? 1 : safe_page_params
    @posts = HacksterBlogPost.published
    if params[:tag]
      @posts = @posts.joins(:blog_tags).where(tags: { name: params[:tag] })
    end
    @posts = @posts.paginate(page: @page)

    respond_to do |format|
      format.html
      format.atom { render layout: false }
      format.rss { redirect_to blog_index_path(params.merge(format: :atom)), status: :moved_permanently }
    end

    track_event 'Visited blog'
  end

  def show
    if user_signed_in? and current_user.is? :admin
      @post = HacksterBlogPost.find_by_slug! params[:slug]
    else
      @post = HacksterBlogPost.published.find_by_slug! params[:slug]
    end

    meta_desc ActionController::Base.helpers.strip_tags(@post.body).truncate 155
    title @post.title

    track_event 'Visited blog post', { id: @post.id, title: @post.title }
  end

  def feed
    @posts = HacksterBlogPost.published.limit(25)
  end

  private
    def meta_desc meta_desc=nil
      if meta_desc
        @meta_desc = meta_desc
      else
        @meta_desc || "#{SLOGAN} Share your projects and learn from other makers. Come build awesome hardware!"
      end
    end

    def title title=nil
      if title
        @title = title
      else
        @title ? "#{@title} - Hackster.io's blog" : "Hackster.io's blog"
      end
    end
end