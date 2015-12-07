class Api::V1::CommentsController < Api::V1::BaseController
  before_filter :authenticate_user!, :except => [:index]

  def index
    surrogate_keys = [Comment.cache_key(params[:type], params[:id])]
    surrogate_keys << current_platform.user_name if is_whitelabel?
    set_surrogate_key_header *surrogate_keys
    set_cache_control_headers

    @comments = Comment.where(commentable_type: params[:type], commentable_id: params[:id]).includes(user: :avatar)
  end

  def create
    commentable = params[:commentable][:type].classify.constantize.find(params[:commentable][:id])
    @comment = commentable.comments.build(params[:comment])
    authorize! :create, @comment
    @comment.user = current_user

    if @comment.save
      @comment
    else
      render json: { errors: @comment.errors }, status: :unprocessable_entity
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
