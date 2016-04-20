class Mouser::Api::SubmissionsController < Mouser::Api::BaseController
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
end