class WidgetsController < ApplicationController
  before_filter :load_project
  before_filter :authenticate_user!
  before_filter :set_project_mode
  load_and_authorize_resource except: [:new, :create, :save]
  respond_to :html, :js
  layout 'project'

  def index
#    @widgets = @project.widgets
  end

  def save
    authorize! :update, @project
    # so it doesn't block if there's validation errors on the project
    @project.assign_attributes(params[:project])
    if @project.save(validate: false)
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

    if @widget.save
      respond_to do |format|
        format.html { redirect_to edit_project_widget_path(@project, @widget) }
        format.js
      end

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
      current_user.broadcast :update, @project.id, 'Project', @project.id if @project.public?
      respond_to do |format|
        format.html do
          flash[:notice] = 'Widget saved.'
          session[:last_widget_edited] = @widget.class.name.underscore
          respond_with @project
        end
        format.js
      end

      track_event 'Updated project', @project.to_tracker.merge({ type: 'widget update' }).merge(@widget.to_tracker)
    else
      render 'edit'
    end
  end

  def destroy
    @widget.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = 'Widget deleted.'
        respond_with @project
      end
      format.js { render status: :ok }
    end

    track_event 'Updated project', @project.to_tracker.merge({ type: 'widget deleted' }).merge(@widget.to_tracker)
  end
end