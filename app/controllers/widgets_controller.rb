class WidgetsController < ApplicationController
  before_filter :load_stage
  load_resource
  skip_load_resource :create
  respond_to :html

  def new
  end

  def create
    @widget = @stage.widgets.create(params[:widget])

    if @widget.save
      redirect_to edit_stage_widget_path(@stage, @widget)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @widget.update_attributes params[@widget.type.underscore]
      flash[:notice] = 'Widget saved.'
      respond_with @stage.project
    else
      render 'edit'
    end
  end

  def destroy
    @widget.destroy

    flash[:notice] = 'Widget deleted.'
    respond_with @stage.project
  end

  private
    def load_stage
      @stage = Stage.find params[:stage_id]
    end
end