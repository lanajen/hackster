class Api::V1::PlatformsController < Api::V1::BaseController
  # before_filter :public_api_methods, only: [:index, :show]
  before_filter :load_platform, only: [:show]
  before_filter :load_projects, only: [:show]

  def index
    render json: Platform.order(full_name: :asc)
  end

  def show
    render json: { platform: { name: @platform.name, url: platform_short_url(@platform) }, projects: @projects.map{|c| project = c.project; { name: project.name, url: project_url(project), embed_url: project_embed_url(project), cover_image_url: project.cover_image.try(:file_url, :cover_thumb), one_liner: project.one_liner, author_names: project.users.map(&:name).to_sentence, views: project.impressions_count, comments: project.comments_count, respects: project.respects_count } } }
  end

  private
    def load_projects
      per_page = begin; [Integer(params[:per_page]), Project.per_page].min; rescue; Project.per_page end;  # catches both no and invalid params

      sort = params[:sort] ||= 'magic'
      @by = params[:by] || 'all'

      sort = if params[:sort] and params[:sort].in? Project::SORTING.keys
        params[:sort]
      else
        params[:sort] = @platform.project_sorting.presence || 'magic'
      end
      @by = params[:by] || 'all'

      @projects = @platform.project_collections.includes(:project).visible.order('project_collections.workflow_state DESC').merge(Project.for_thumb_display_in_collection)
      @projects = @projects.merge(Project.send(Project::SORTING[sort]))

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
      @platform = Platform.find_by_user_name! params[:user_name]
    end
end