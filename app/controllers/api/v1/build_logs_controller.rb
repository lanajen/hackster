class Api::V1::BuildLogsController < Api::V1::BaseController
  # before_filter :public_api_methods, only: [:index, :show]

  def index
    render json: BlogPost.order(created_at: :desc).limit(10)
  end

  def show
    blog_post = BlogPost.find params[:id]
    render json: blog_post
  end

  def create
    blog_post = BlogPost.new params[:blog_post]
    authorize! :create, blog_post

    if blog_post.save
      render json: blog_post, status: :ok
    else
      render json: blog_post.errors, status: :unprocessable_entity
    end
  end

  def update
    blog_post = BlogPost.find params[:id]
    authorize! :update, blog_post

    if blog_post.update_attributes params[:blog_post]
      render json: blog_post, status: :ok
    else
      errors = blog_post.errors.messages
      widget_errors = {}
      blog_post.widgets.each{|w| widget_errors[w.id] = w.to_error if w.errors.any? }
      errors['widgets'] = widget_errors
      render json: errors, status: :bad_request
    end
  end

  def destroy
    blog_post = BlogPost.find(params[:id])
    authorize! :destroy, blog_post
    blog_post.destroy

    render json: 'Destroyed'
  end
end