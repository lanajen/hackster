class SparkfunWishlistsController < MainBaseController
  before_filter :authenticate_user!, only: [:create]

  def create
    if params[:wishlist_id].present?
      @project = Project.create private: true
      job_id = SparkfunWishlistWorker.perform_async 'import', @project.id, params[:wishlist_id], current_user.id

      render json: { job_id: job_id, next_url: edit_project_path(@project) }
    else
      head(:unprocessable_entity)
    end
  end
end