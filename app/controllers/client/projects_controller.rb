class Client::ProjectsController < Client::BaseController
  load_and_authorize_resource only: [:index]
  respond_to :html

  def index
    title = "#{current_platform.name} projects"
    title += " - Page #{safe_page_params}" if safe_page_params
    title title

    impressionist_async current_tech, "", unique: [:session_hash]

    sort = params[:sort] ||= 'magic'
    @by = params[:by] || 'all'

    @projects = current_tech.project_collections.includes(:project).visible.order('project_collections.workflow_state DESC').merge(Project.indexable_and_external.for_thumb_display_in_collection)
    if sort and sort.in? Project::SORTING.keys
      @projects = @projects.merge(Project.send(Project::SORTING[sort]))
    end

    if @by and @by.in? Project::FILTERS.keys
      @projects = if @by == 'featured'
        @projects.featured
      else
        @projects.merge(Project.send(Project::FILTERS[@by]))
      end
    end

    @projects = @projects.paginate(page: safe_page_params)
    @challenge = current_tech.active_challenge ? current_tech.challenges.active.first : nil

    respond_to do |format|
      format.html { render layout: 'whitelabel' }
      format.atom { render layout: false }
      format.rss { redirect_to projects_path(params.merge(format: :atom)), status: :moved_permanently }
    end
  end
end
