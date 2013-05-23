class WidgetsController < ApplicationController
  before_filter :load_project
  load_resource except: [:new, :create]
  respond_to :html
  layout 'project'

  def new
    @widget = @project.widgets.new(params[:widget])
  end

  def create
    @widget = @project.widgets.new(params[:widget])
    @widget.stage_id = 0

    if @widget.save
      redirect_to edit_project_widget_path(@project, @widget)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @widget.update_attributes params[:widget]
      flash[:notice] = 'Widget saved.'
      current_user.broadcast :update, @project.id, 'Project'
      respond_with @project
    else
      render 'edit'
    end
  end

  def destroy
    @widget.destroy

    flash[:notice] = 'Widget deleted.'
    respond_with @project
  end

  private
#    def load_stage
#      @stage = Stage.find params[:stage_id]
#      @project = @stage.project
#      authorize! :update_widgets, @project
#    end
end