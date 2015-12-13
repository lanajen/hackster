class Api::V1::CommentsController < Api::V1::BaseController
  before_filter :authenticate_user!, :except => [:index]
  protect_from_forgery only: [:create, :destroy]
  include WidgetsHelper

  def index
    cache_key = Comment.cache_key(params[:type], params[:id])
    surrogate_keys = [cache_key, 'comments']
    surrogate_keys << current_platform.user_name if is_whitelabel?
    set_surrogate_key_header *surrogate_keys
    set_cache_control_headers 86400  # expires in 24 hours

    @comments = Comment.where(commentable_type: params[:type], commentable_id: params[:id]).order(created_at: :asc).includes(user: :avatar)

    render json: CommentCollectionJsonDecorator.new(sort_comments(@comments)).node.to_json
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
