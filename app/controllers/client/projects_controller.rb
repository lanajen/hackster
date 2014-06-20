class Client::ProjectsController < Client::BaseController
  load_and_authorize_resource only: [:index]
  respond_to :html

  def index
    title = "#{current_platform.name} projects"
    title += " - Page #{params[:page]}" if params[:page]
    title title

    impressionist_async current_tech, "", unique: [:session_hash]

    params[:sort] ||= 'magic'
    @by = params[:by] || 'all'

    @projects = current_tech.projects.visible.indexable_and_external
    if params[:sort] and params[:sort].in? Project::SORTING.keys
      @projects = @projects.send(Project::SORTING[params[:sort]])
    end

    if params[:by] and params[:by].in? Project::FILTERS.keys
      @projects = @projects.send(Project::FILTERS[params[:by]])
    end

    @projects = @projects.paginate(page: params[:page])

    respond_to do |format|
      format.html { render layout: 'whitelabel' }
      format.atom { render layout: false }
      format.rss { redirect_to projects_path(params.merge(format: :atom)), status: :moved_permanently }
    end
  end
end
