class Api::PrivateDoorkeeper::ProjectsController < Api::PrivateDoorkeeper::BaseController
  before_filter -> { doorkeeper_authorize! :write_project }
  before_filter :load_and_authorize_resource

  def description
    if @project.story_json.nil? and @project.description.present?
      render json: { description: @project.decorate.description, story: nil }
    elsif @project.story_json.present?
      render json: { description: nil, story: StoryJsonJsonDecorator.new(@project.story_json).to_json }
    else
      render json: { description: '', story: nil }
    end
  end

  private
    def load_and_authorize_resource
      @project = BaseArticle.find params[:project_id] || params[:id]
      authorize! self.action_name, @project
    end
end
#