class Client::ProjectsController < Client::BaseController
  load_and_authorize_resource only: [:index]
  respond_to :html

  def index
    title = "#{current_platform.name} projects"
    title += " - Page #{safe_page_params}" if safe_page_params
    title title

    impressionist_async current_platform, "", unique: [:session_hash]

    sort = params[:sort] || 'magic'
    @by = params[:by] || 'all'

    @projects = current_platform.projects.visible.indexable_and_external.for_thumb_display
    if sort and sort.in? Project::SORTING.keys
      @projects = @projects.send(Project::SORTING[sort])
    end

    if @by and @by.in? Project::FILTERS.keys
      @projects = if @by == 'featured'
        @by = 'gfeatured'
        @projects.send(Project::FILTERS[@by], 'Group', current_platform.id)
      else
        @projects.send(Project::FILTERS[@by])
      end
    end

    @projects = @projects.paginate(page: safe_page_params)
    @challenge = current_platform.active_challenge ? current_platform.challenges.active.first : nil

    respond_to do |format|
      format.html { render layout: 'whitelabel' }
      format.atom { render layout: false }
      format.rss { redirect_to projects_path(params.merge(format: :atom)), status: :moved_permanently }
    end
  end
end
