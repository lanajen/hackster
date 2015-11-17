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

    projects = if params[:platform_user_name]
      parent = Platform.find_by_user_name! params[:platform_user_name]
      if params[:part_mpn]
        parent = parent.parts.find_by_mpn! params[:part_mpn]
      end
      parent.projects
    else
      BaseArticle
    end

    projects = projects.indexable.for_thumb_display

    if params[:sort]
      projects = projects.send(BaseArticle::SORTING[params[:sort]])
    end

    if by and by.in? BaseArticle::FILTERS.keys
      projects = projects.send(BaseArticle::FILTERS[by])
    end

    @projects = projects.paginate(page: safe_page_params)
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