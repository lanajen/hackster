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
    render json: { platform: { name: @platform.name, url: platform_home_url(@platform) }, projects: @projects.map{|c| project = c.project; { name: project.name, url: project_url(project), embed_url: project_embed_url(project), cover_image_url: project.cover_image.try(:file_url, :cover_thumb), one_liner: project.one_liner, author_names: project.users.map(&:name).to_sentence, views: project.impressions_count, comments: project.comments_count, respects: project.respects_count } } }
  end

  def analytics
    load_analytics

    sql = "SELECT projects.*, t1.count FROM (SELECT respects.respectable_id as project_id, COUNT(*) as count FROM respects INNER JOIN project_collections ON project_collections.project_id = respects.respectable_id WHERE respects.respectable_type = 'Project' AND project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? GROUP BY respects.respectable_id) AS t1 INNER JOIN projects ON projects.id = t1.project_id WHERE t1.count > 1 AND projects.private = 'f' AND projects.approved = 't' ORDER BY t1.count DESC LIMIT 50;"
    @project_respects = Project.find_by_sql([sql, @platform.id])

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