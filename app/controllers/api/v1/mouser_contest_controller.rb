class Api::V1::MouserContestController < Api::V1::BaseController

  def index
    #display all of the currently competing platforms
    render json: MouserSubmission.last()
  end

  def show

  end

  def create

    # INCOMING JSON { userId, projectId, description }

    @submission = JSON.parse(request.body.read)
    @user_id = @submission['userId']
    @project_id = @submission['projectId']
    @description = @submission['description']

    # this should save author (user_id) - project (project_id) - status - vendor (platform_id)

    logger.info @submission
    # user = MouserSubmission.create(user_id: @user_id, project_id: @project_id, project_name: @description)
    MouserSubmission.find_or_create_by(user_id: @user_id, project_id: @project_id, project_name: @description)

    render text: 'POST successful'
  end

  private
    def load_platform
      @platform = Platform.find_by_user_name! params[:user_name]
    end
end