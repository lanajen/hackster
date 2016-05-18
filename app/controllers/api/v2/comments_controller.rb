class Api::V2::CommentsController < Api::V2::BaseController
  include WidgetsHelper
  before_filter :doorkeeper_authorize_without_scope!, only: [:index]
  before_filter -> { doorkeeper_authorize! :comment }, only: [:create, :update, :destroy]

  def index
    cache_key = Comment.cache_key(params[:type], params[:id])
    surrogate_keys = [cache_key, 'comments']
    surrogate_keys << current_platform.user_name if is_whitelabel?
    set_surrogate_key_header *surrogate_keys
    set_cache_control_headers 86400  # expires in 24 hours

    @comments = Comment.where(commentable_type: params[:type], commentable_id: params[:id]).order(created_at: :asc).includes(user: :avatar).includes(:likes)

    opts = { current_site: current_site, url_opts: { path_prefix: current_site.try(:path_prefix).presence } }

    render json: CommentCollectionJsonDecorator.new(sort_comments(@comments), opts).sorted_node.to_json
  end

  def create
    commentable = params[:commentable][:type].classify.constantize.find(params[:commentable][:id])
    comment = commentable.comments.build(params[:comment])
    authorize! :create, comment
    comment.user = current_user

    if comment.save
      render json: { comment: CommentJsonDecorator.new(comment).node }
    else
      render json: { errors: comment.errors }, status: :unprocessable_entity
    end
  end

  def update
    comment = Comment.find(params[:id])
    authorize! :update, comment
    if comment.update_attributes(params[:comment])
      render json: { comment: CommentJsonDecorator.new(comment).node }
    else
      render json: { comment: comment.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    comment = Comment.find(params[:id])
    authorize! :destroy, comment
    comment.destroy

    render json: { comment: comment }, status: :ok
  end

  private
    def find_commentable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          return $1.classify.constantize.find(value)
        end
      end
    end
end
