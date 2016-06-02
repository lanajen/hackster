class Api::V1::ProjectsController < Api::V1::BaseController
  def index
    set_surrogate_key_header 'api/projects'
    set_cache_control_headers

    params[:sort] = (params[:sort].in?(BaseArticle::SORTING.keys) ? params[:sort] : 'trending')
    by = (params[:by].in?(BaseArticle::FILTERS.keys) ? params[:by] : 'all')

    range_start = begin; DateTime.parse(params[:range_start]); rescue; Time.at(0); end
    range_end = begin; DateTime.parse(params[:range_end]); rescue; Time.now; end

    projects = if params[:part_mpns]
      BaseArticle.joins(:parts).where(parts: { mpn: params[:part_mpns].split(/,/) })
    elsif params[:platform_user_name]
      platform = Platform.find_by_user_name! params[:platform_user_name]
      @url = group_url(platform, subdomain: 'www')
      if params[:part_mpn]
        part = platform.parts.find_by_mpn!(params[:part_mpn])
        @url = part_url(part, subdomain: 'www') if part.has_own_page?
        part.projects
      else
        platform.project_collections.references(:project).includes(:project).visible.where("project_collections.updated_at > ? AND project_collections.updated_at < ?", range_start, range_end)
      end
    else
      BaseArticle.where("projects.made_public_at > ? AND projects.made_public_at < ?", range_start, range_end)
    end

    projects = if params[:platform_user_name] or params[:part_mpn] or params[:part_mpns]
      projects.where("projects.private = 'f'")
    else
      projects.indexable
    end

    if by and by.in? BaseArticle::FILTERS.keys
      if params[:platform_user_name] and !params[:part_mpn]
        projects = projects.merge(BaseArticle.send(BaseArticle::FILTERS[by]))
      else
        projects = projects.send(BaseArticle::FILTERS[by])
      end
    end

    if params[:type]
      projects = projects.where("projects.type = ?", params[:type])
    end

    if params[:only_count]
      @count = projects.count
    else
      if params[:sort]
        if params[:platform_user_name] and !params[:part_mpn]
          projects = projects.merge(BaseArticle.send(BaseArticle::SORTING[params[:sort]]))
        else
          projects = projects.send(BaseArticle::SORTING[params[:sort]])
        end
      end

      if params[:platform_user_name] and !params[:part_mpn]
        @collections = projects.merge(BaseArticle.for_thumb_display_in_collection).paginate(page: safe_page_params)
      else
        @projects = projects.for_thumb_display.paginate(page: safe_page_params)
      end
    end
  end

  def show
    @project = BaseArticle.where(id: params[:id]).publyc.first!
    @with_details = true

    set_surrogate_key_header "api/projects/#{@project.id}"
    set_cache_control_headers
  end
end