class Api::V1::PlatformsController < Api::V1::BaseController
  # before_filter :public_api_methods, only: [:index, :show]
  before_filter :load_platform, only: [:show]
  before_filter :load_projects, only: [:show]

  def index
    render json: Platform.order(full_name: :asc)
  end

  def show
    render json: { platform: { name: @platform.name, url: platform_short_url(@platform) }, projects: @projects.map{|c| { name: c.project.name, url: project_url(c.project) } } }
  end

  private
    def load_projects
      per_page = begin; [Integer(params[:per_page]), Project.per_page].min; rescue; Project.per_page end;  # catches both no and invalid params

      sort = params[:sort] ||= 'magic'
      @by = params[:by] || 'all'

      @projects = @platform.project_collections.includes(:project).visible.order('project_collections.workflow_state DESC').merge(Project.indexable_and_external.for_thumb_display_in_collection)
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

      @projects = @projects.paginate(page: safe_page_params, per_page: per_page)
    end

    def load_platform
      @platform = Platform.find params[:id]
    end
end