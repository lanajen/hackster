class CommentsController < ApplicationController
  before_filter :authenticate_user!, except: [:create]
  load_and_authorize_resource
  skip_load_resource only: [:create]

  # POST /comments
  # POST /comments.json
  def create
    @commentable = find_commentable
    @comment = @commentable.comments.build(params[:comment])
    @comment.user = current_user if current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to path_for_commentable(@commentable), notice: t('comment.create.success') }
#        format.json { render json: @comment, status: :created, location: @comment }
        format.js { render js_view_for_commentable(@commentable) }
      else
        format.html { redirect_to path_for_commentable(@commentable), alert: t('comment.create.error') }
#        format.json { render json: @comment.errors, status: :unprocessable_entity }
        format.js { render 'error' }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to path_for_commentable(@commentable), notice: t('comment.update.success') }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @commentable = @comment.commentable
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to path_for_commentable(@commentable), notice: t('comment.destroy.success') }
      format.js { render js_view_for_commentable(@commentable) }
    end
  end

  private
    def find_commentable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          return $1.classify.constantize.find(value)
        end
      end
    end

    def js_view_for_commentable commentable
      case commentable
      when Project
        'update_project'
      when Widget
        'update_widget'
      end
    end

    def path_for_commentable commentable
      case commentable
      when BlogPost
        project_blog_post_path(commentable.threadable, commentable)
      when Issue
        issue_path(commentable)
      when Project
        project_path(commentable)
      when Widget
        project_path(commentable.project)
      end
    end
end
