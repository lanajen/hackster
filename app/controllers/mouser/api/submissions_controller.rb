class Mouser::Api::SubmissionsController < Mouser::Api::BaseController
  def create
    submission_data = JSON.parse(request.body.read)
    MouserSubmission.find_or_create_by(user_id: submission_data['user_id'], project_id: submission_data['project_id']) do |user|
      user.user_id = submission_data['user_id']
      user.project_id = submission_data['project_id']
      user.vendor_user_name = submission_data['vendor_user_name']
      user.workflow_state = submission_data['workflow_state']
    end

    render status: 200, nothing: true
  end

  def update
    update = JSON.parse(request.body.read)

    submission = MouserSubmission.find_by(project_id: params[:id])
    submission.workflow_state = update['status']
    submission.save

    render status: 200, nothing: true
  end
end