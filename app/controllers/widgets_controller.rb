class WidgetsController < ApplicationController
  before_filter :load_project
  before_filter :authenticate_user!
  load_and_authorize_resource except: [:new, :create, :save]
  respond_to :html, :js
  layout 'project'

  def index
#    @widgets = @project.widgets
  end

  def save
    authorize! :update, @project
    if @project.update_attributes(params[:project])
      redirect_to @project, notice: "Layout saved."

      track_event 'Updated project', @project.to_tracker.merge({ type: 'layout update'})
    else
      render action: 'index'
    end
  end

  def new
    @widget = @project.widgets.new(params[:widget])
    title "Edit #{@project.name}"
    authorize! :create, @widget
  end

  def create
    @widget = @project.widgets.new(params[:widget])
    authorize! :create, @widget
    @widget.stage_id = 0

    if @widget.save
      redirect_to edit_project_widget_path(@project, @widget)

      track_event 'Updated project', @project.to_tracker.merge({ type: 'widget created' }).merge(@widget.to_tracker)
    else
      render 'new'
    end
  end

  def edit
    title "Edit #{@project.name}"
  end

  def update
    if @widget.update_attributes params[:widget]
      flash[:notice] = 'Widget saved.'
      current_user.broadcast :update, @project.id, 'Project' if @project.public?
      respond_with @project

      track_event 'Updated project', @project.to_tracker.merge({ type: 'widget update' }).merge(@widget.to_tracker)
    else
      render 'edit'
    end
  end

  def destroy
    @widget.destroy

    flash[:notice] = 'Widget deleted.'
    respond_with @project

    track_event 'Updated project', @project.to_tracker.merge({ type: 'widget deleted' }).merge(@widget.to_tracker)
  end

  private
#    def load_stage
#      @stage = Stage.find params[:stage_id]
#      @project = @stage.project
#      authorize! :update_widgets, @project
#    end
end