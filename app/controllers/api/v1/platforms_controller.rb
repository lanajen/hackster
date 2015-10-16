class Api::V1::PlatformsController < Api::V1::BaseController
  include PlatformHelper
  # before_filter :public_api_methods, only: [:index, :show]
  before_filter :load_platform, only: [:show, :analytics]
  before_filter :authenticate, only: [:analytics]
  before_filter :load_projects, only: [:show]

  def index
    render json: Platform.order(full_name: :asc)
  end

  def show
    set_surrogate_key_header "api/platforms/#{@platform.id}/projects"
    set_cache_control_headers 3600
  end

  def analytics
    load_analytics

    sql = "SELECT projects.*, t1.count FROM (SELECT respects.respectable_id as project_id, COUNT(*) as count FROM respects INNER JOIN project_collections ON project_collections.project_id = respects.respectable_id WHERE respects.respectable_type = 'BaseArticle' AND project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? GROUP BY respects.respectable_id) AS t1 INNER JOIN projects ON projects.id = t1.project_id WHERE t1.count > 1 AND projects.private = 'f' AND projects.workflow_state = 'approved' ORDER BY t1.count DESC LIMIT 50;"
    @project_respects = BaseArticle.find_by_sql([sql, @platform.id])

    render "groups/platforms/#{self.action_name}"
  end

  private
    def authenticate
      return true if Rails.env == 'development'

      authenticate_or_request_with_http_basic do |username, password|
        username == @platform.api_username && password == @platform.api_password
      end
    end

    def load_platform
      @platform = Platform.find_by_user_name! params[:user_name]
    end
end