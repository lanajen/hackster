class Client::ProjectsController < Client::BaseController
  load_and_authorize_resource only: [:index]
  respond_to :html

  def index
    title "Projects - Page #{safe_page_params}" if safe_page_params

    impressionist_async current_platform, "", unique: [:session_hash]

    params[:sort] = (params[:sort].in?(Project::SORTING.keys) ? params[:sort] : 'trending')
    @by = (params[:by].in?(Project::FILTERS.keys) ? params[:by] : 'all')

    @projects = current_platform.project_collections.where(users: { enable_sharing: true }).includes(:project).visible.order('project_collections.workflow_state DESC').merge(Project.indexable_and_external.for_thumb_display_in_collection)
    if params[:sort]
      @projects = @projects.merge(Project.send(Project::SORTING[params[:sort]]))
    end

    if @by and @by.in? Project::FILTERS.keys
      @projects = if @by == 'featured'
        @projects.featured
      else
        @projects.merge(Project.send(Project::FILTERS[@by]))
      end
    end

    @projects = @projects.paginate(page: safe_page_params, per_page: Project.per_page)
    @challenge = current_platform.active_challenge ? current_platform.challenges.active.first : nil

    respond_to do |format|
      format.html { render layout: 'whitelabel' }
      format.atom { render layout: false }
      format.rss { redirect_to projects_path(params.merge(format: :atom)), status: :moved_permanently }
    end
  end
end
