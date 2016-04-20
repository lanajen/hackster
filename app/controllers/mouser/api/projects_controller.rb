class Mouser::Api::ProjectsController < Mouser::Api::BaseController
  def index
    projects = BaseArticle.publyc.own.joins(:users).where(users: { id: params[:user_id] })
    @projects = projects.for_thumb_display.paginate(page: safe_page_params)
  end
end