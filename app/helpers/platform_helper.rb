module PlatformHelper
  def load_projects options={}
    per_page = begin; [Integer(params[:per_page]), Project.per_page].min; rescue; Project.per_page end;  # catches both no and invalid params

    return unless platform = options[:platform] || @platform
    options[:type] ||= %w(Project ExternalProject)
    per_page = per_page - 1 if !options[:disable_ideas] and platform.accept_project_ideas and !options[:type] == 'Product'

    sort = if params[:sort] and params[:sort].in? Project::SORTING.keys
      params[:sort]
    else
      params[:sort] = platform.project_sorting.presence || 'trending'
    end
    @by = params[:by] || 'all'

    @projects = platform.project_collections.includes(:project).visible.order('project_collections.workflow_state DESC').merge(Project.for_thumb_display_in_collection)
    @projects = if sort == 'recent'
      @projects.most_recent
    else
      @projects.merge(Project.send(Project::SORTING[sort]))
    end

    if options[:type]
      @projects = @projects.joins(:project).merge(Project.where(type: options[:type]))  # fails without joins
    end

    if params[:tag]
      @projects = @projects.joins(:project).joins(project: :product_tags).where("LOWER(tags.name) = ?", CGI::unescape(params[:tag]))
    end

    if @by and @by.in? Project::FILTERS.keys
      @projects = if @by == 'featured'
        @projects.featured
      else
        @projects.merge(Project.send(Project::FILTERS[@by]))
      end
    end

    @projects = @projects.paginate(page: safe_page_params, per_page: per_page)
  end
end