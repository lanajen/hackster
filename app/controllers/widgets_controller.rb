class WidgetsController < ApplicationController
  before_filter :load_project
  load_and_authorize_resource except: [:new, :create, :save]
  respond_to :html
  layout 'project'

  def index
#    @widgets = @project.widgets
  end

  def save
    authorize! :update, @project
    if @project.update_attributes(params[:project])
      redirect_to @project, notice: "Layout saved."
    else
      render action: 'index'
    end
  end

  def new
    @widget = @project.widgets.new(params[:widget])
    authorize! :create, @widget
  end

  def create
    @widget = @project.widgets.new(params[:widget])
    authorize! :create, @widget
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