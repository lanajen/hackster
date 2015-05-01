class Client::ProjectsController < Client::BaseController
  include PlatformHelper

  load_and_authorize_resource only: [:index]
  skip_before_filter :track_visitor, only: [:index]
  skip_after_filter :track_landing_page, only: [:index]
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

    @challenge = current_platform.active_challenge ? current_platform.challenges.active.first : nil

    respond_to do |format|
      format.html { render layout: 'whitelabel' }
      format.atom { render layout: false }
      format.rss { redirect_to projects_path(params.merge(format: :atom)), status: :moved_permanently }
    end
  end
end
