class Mouser::Api::ProjectsController < Mouser::Api::BaseController
  def index
    projects = BaseArticle.publyc.own.where(type: 'Project').joins(:users).where(users: { id: params[:user_id] })
    submissions = MouserSubmission.where(user_id: params[:user_id])

    render json: { projects: ProjectCollectionJsonDecorator.new(projects).node, submissions: submissions }
  end
end