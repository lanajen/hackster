class Api::V1::PlatformAnalyticsController < Api::V1::BaseController
  include PlatformHelper
  before_filter :authenticate_api_user

  def show
    load_analytics

    sql = "SELECT projects.*, t1.count FROM (SELECT respects.respectable_id as project_id, COUNT(*) as count FROM respects INNER JOIN project_collections ON project_collections.project_id = respects.respectable_id WHERE respects.respectable_type = 'BaseArticle' AND project_collections.collectable_type = 'Group' AND project_collections.collectable_id = ? GROUP BY respects.respectable_id) AS t1 INNER JOIN projects ON projects.id = t1.project_id WHERE t1.count > 1 AND projects.private = 'f' AND projects.workflow_state = 'approved' ORDER BY t1.count DESC LIMIT 50;"
    @project_respects = BaseArticle.find_by_sql([sql, @platform.id])
  end

  def projects
    @range_start = params[:range_start] || Time.at(0)
    @range_end = params[:range_end] || Time.now
    @projects = @platform.projects.includes(:users).paginate(per_page: 10, page: safe_page_params)
  end
end