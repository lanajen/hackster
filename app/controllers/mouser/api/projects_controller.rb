class Mouser::Api::ProjectsController < Mouser::Api::BaseController
  def index
    projects = BaseArticle.publyc.own.joins(:users).where(users: { id: params[:user_id] })
    render json: ProjectJsonDecorator.new(projects).node
  end
end