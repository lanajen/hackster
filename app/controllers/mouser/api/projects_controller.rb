class Mouser::Api::ProjectsController < Mouser::Api::BaseController
  def index
    projects = BaseArticle.publyc.own.joins(:users).where(users: { id: params[:user_id] })
    # render json: BaseCollectionJsonDecorator.new(projects).node
    render json: projects
  end
end