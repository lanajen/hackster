class Mouser::Api::SubmissionsController < Mouser::Api::BaseController
  def create
    submission_data = JSON.parse(request.body.read)
    MouserSubmission.find_or_create_by(user_id: @submission['userId'], project_id: @submission['projectId']) do |user|
      user.project_name = submission['description']
      user.vendor_id = submission['vendor_id']
      user.vendor_tags = submission['vendor_tags']
      user.status = 'undecided'
    end

    render status: 200
  end

  def update
    update = JSON.parse(request.body.read)

    submission = MouserSubmission.find_by(project_id: params[:id])
    submission.status = @update['status']
    submission.save

    render status: 200
  end
end