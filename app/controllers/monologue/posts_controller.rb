class Monologue::PostsController < Monologue::ApplicationController
  def index
    @page = safe_page_params.nil? ? 1 : safe_page_params
    @posts = Monologue::Post.published.page(@page)
    track_event 'Visited blog'
  end

  def show
    if monologue_current_user
      @post = Monologue::Post.default.where("url = :url", {url: params[:post_url]}).first
    else
      @post = Monologue::Post.published.where("url = :url", {url: params[:post_url]}).first
    end
    if @post.nil?
      not_found
    else
      track_event 'Visited blog post', { id: @post.id, title: @post.title }
    end
  end

  def feed
    @posts = Monologue::Post.published.limit(25)
  end
end