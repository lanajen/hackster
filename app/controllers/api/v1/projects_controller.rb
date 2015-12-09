class Api::V1::ProjectsController < Api::V1::BaseController
  before_filter :public_api_methods, only: [:index, :show]
  before_filter :authenticate_user!, only: [:create, :update, :destroy]
  before_filter :load_and_authorize_resource, only: [:create, :update, :destroy]
  skip_before_filter :track_visitor, only: [:index]
  skip_after_filter :track_landing_page, only: [:index]

  def index
    set_surrogate_key_header 'api/projects'
    set_cache_control_headers

    params[:sort] = (params[:sort].in?(BaseArticle::SORTING.keys) ? params[:sort] : 'trending')
    by = (params[:by].in?(BaseArticle::FILTERS.keys) ? params[:by] : 'all')

    projects = if params[:part_mpns]
      BaseArticle.joins(:parts).where(parts: { mpn: params[:part_mpns].split(/,/) })
    elsif params[:platform_user_name]
      platform = Platform.find_by_user_name! params[:platform_user_name]
      @url = group_url(platform, subdomain: 'www')
      platform
      if params[:part_mpn]
        part = platform.parts.find_by_mpn!(params[:part_mpn])
        @url = part_url(part, subdomain: 'www') if part.has_own_page?
        part.projects
      else
        platform.projects.visible
      end
    else
      BaseArticle
    end

    projects = if params[:platform_user_name] or params[:part_mpn] or params[:part_mpns]
      projects.publyc
    else
      projects.indexable
    end

    if by and by.in? BaseArticle::FILTERS.keys
      projects = projects.send(BaseArticle::FILTERS[by])
    end

    if params[:only_count]
      @count = projects.count
    else
      if params[:sort]
        projects = projects.send(BaseArticle::SORTING[params[:sort]])
      end

      @projects = projects.for_thumb_display.paginate(page: safe_page_params)
    end
  end

  def show
    @project = BaseArticle.where(id: params[:id]).public.first!
  end

  def create
    if project.save
      render status: :ok, nothing: true
    else
      render json: project.errors, status: :unprocessable_entity
    end
  end

  def update
    if @project.update_attributes(params[:base_article])
      render status: :ok, nothing: true
    else
      render json: { base_article: @project.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy

    render status: :ok, nothing: true
  end

  private
    def load_and_authorize_resource
      @project = BaseArticle.find params[:project_id] || params[:id]
      authorize! self.action_name, @project
    end
end