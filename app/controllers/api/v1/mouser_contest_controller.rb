class Api::V1::MouserContestController < Api::V1::BaseController

  def index
    #display all of the currently competing platforms
    render json: MouserSubmission.last()
  end

  def show

  end

  def create
    p request.body
    render json: 'hello'
    # we're set up to save to the db here!!x
    # user = MouserSubmission.create(user_id: 1, project_id: 1)
  end

  private
    def load_platform
      @platform = Platform.find_by_user_name! params[:user_name]
    end
end