class Api::V1::ProjectsController < Api::V1::BaseController

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
    elsif params[:user_id]
      # user = User.find params[:user_id]
      # user.projects.publyc
      BaseArticle.publyc.own.joins(:users).where(users: { id: params[:user_id] })
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
    @project = BaseArticle.where(id: params[:id]).publyc.first!
    @with_details = true

    set_surrogate_key_header "api/projects/#{@project.id}"
    set_cache_control_headers
  end
end