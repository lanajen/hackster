class Api::V1::MouserContestController < Api::V1::BaseController

  def index
    #display all of the currently competing platforms
    render json: MouserSubmission.last()
  end

  def show

  end

  def create
    @submission = JSON.parse(request.body.read)

    logger.info @submission

    MouserSubmission.find_or_create_by(user_id: @submission['userId'], project_id: @submission['projectId']) do |user|
      user.project_name = @submission['description']
      user.vendor_id = @submission['vendor']
      user.status = 'undecided'
    end

    render text: 'POST successful'
  end

  private
    def load_platform
      @platform = Platform.find_by_user_name! params[:user_name]
    end
end