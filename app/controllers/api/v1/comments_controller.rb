class Api::V1::CommentsController < Api::V1::BaseController
  before_filter :authenticate_user!, :except => [:index]
# example whitelist
# render nothing: true, status: :unprocessable_entity and return unless params[:file_url] and params[:file_type] and params[:file_type].in? %w(avatar image cover_image document sketchfab_file logo company_logo favicon)
  def index
    @comments = params[:type].classify.constantize.find(params[:id]).comments.includes(:parent, user: :avatar)
  end

  def create
    commentable = params[:commentable][:type].classify.constantize.find(params[:commentable][:id])
    comment = commentable.comments.build(params[:comment])
    authorize! :create, comment
    comment.user = current_user

    if comment.save
      render json: comment, status: :ok
    else
      render json: comment.errors, status: :unprocessable_entity
    end
  end

  # def edit
  #   comment.body.gsub! /<br>/, "\r\n"
  #   comment.body.gsub! /<\/p>/, "\r\n"
  #   comment.body.gsub! /<p>/, ""
  # end

  # def update
  #   commentable = comment.commentable
  #   respond_to do |format|
  #     if comment.update_attributes(params[:comment])
  #       format.html { redirect_to path_for_commentable(commentable), notice: t('comment.update.success') }
  #       format.js { render 'update_issue' }

  #       track_event 'Edited comment', comment.to_tracker
  #     else
  #       format.html { redirect_to path_for_commentable(commentable), alert: t('comment.update.error') }
  #       format.js { render 'error' }
  #     end
  #   end
  # end

  def destroy
    comment = Comment.find params[:id]
    authorize! :destroy, comment
    commentable = comment.commentable
    comment.destroy

    render json: comment, status: :ok
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
