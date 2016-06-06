class ProjectCollectionsController < MainBaseController
  load_and_authorize_resource

  def edit
  end

  def update
    if @project_collection.update_attributes(params[:project_collection])
      redirect_to @project_collection.collectable, notice: 'Changes saved!'
    else
      render :edit
    end
  end
end