class Client::ProjectsController < Client::BaseController
  include PlatformHelper

  load_and_authorize_resource only: [:index]
  respond_to :html

  def index
    set_surrogate_key_header "home/#{current_platform.user_name}"
    set_cache_control_headers 3600
    title "Projects - Page #{safe_page_params}" if safe_page_params

    impressionist_async current_platform, "", unique: [:session_hash]

    load_projects platform: current_platform, disable_ideas: true

    @challenge = current_platform.active_challenge ? current_platform.challenges.active.first : nil

    respond_to do |format|
      format.html { render layout: 'whitelabel' }
      format.atom { render layout: false }
      format.rss { redirect_to projects_path(params.merge(format: :atom)), status: :moved_permanently }
    end
  end
end
