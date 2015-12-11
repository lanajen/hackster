class Client::ProjectsController < Client::BaseController
  include PlatformHelper

  load_and_authorize_resource only: [:index]
  skip_before_filter :track_visitor, only: [:index]
  skip_after_filter :track_landing_page, only: [:index]
  protect_from_forgery except: :embed
  respond_to :html

  def index
    if user_signed_in?
      impressionist_async current_platform, "", unique: [:session_hash]
    else
      set_surrogate_key_header current_platform.user_name, "#{current_platform.user_name}/home"
      set_cache_control_headers 3600
    end
    title "Projects - Page #{safe_page_params}" if safe_page_params
    @custom_header = template_exists?("whitelabel/#{current_site.subdomain}/all", nil, true)

    load_projects platform: current_platform, disable_ideas: true

    @announcement = current_platform.announcements.current
    @challenge = current_platform.active_challenge ? current_platform.challenges.active.first : nil

    # if params[:show_tags]
    #   @tags = Tag.joins("INNER JOIN projects ON projects.id = tags.taggable_id AND tags.taggable_type = 'BaseArticle'").joins("INNER JOIN project_collections ON project_collections.project_id = projects.id").where(project_collections: { collectable_id: current_platform.id, collectable_type: 'Group', workflow_state: ProjectCollection::VALID_STATES}).where.not("LOWER(tags.name) = ?", current_platform.name.downcase).group("LOWER(tags.name)").order("count_all DESC").limit(10).count.keys
    # end

    respond_to do |format|
      format.html { render layout: 'whitelabel' }
      format.atom { render layout: false }
      format.rss { redirect_to projects_path(params.merge(format: :atom)), status: :moved_permanently }
    end
  end

  def embed
    set_surrogate_key_header "#{current_platform.user_name}/embed"
    set_cache_control_headers 3600

    load_projects platform: current_platform

    respond_to do |format|
      format.js do
        @projects = @projects.map do |project|
          project.project.to_js(subdomain: current_site.subdomain)
        end.to_json
        render "shared/embed"
      end
    end
  end
end
