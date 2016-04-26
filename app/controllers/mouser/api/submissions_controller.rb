class Mouser::Api::SubmissionsController < Mouser::Api::BaseController
  def index
    submissions = MouserSubmission.includes(:project).paginate(page: params[:page], per_page: 20)
    total = submissions.total_entries

    render json: { submissions: MouserSubmissionCollectionJsonDecorator.new(submissions).node, total: total }
  end

  def create
    submission_data = JSON.parse(request.body.read)

    submission_data = {
      project_id: submission_data['project_id'],
      user_id: submission_data['user_id'],
      vendor_user_name: submission_data['vendor_user_name']
    }

    submission = MouserSubmission.new submission_data

    if submission.save
      render status: :ok, nothing: true
    else
      render status: :unprocessable_entity, json: submission.errors
    end
  end

  def update_workflow
    submission = MouserSubmission.find params[:id]

    if submission.send("#{params[:event]}!")
      render status: :ok, nothing: true
    else
      render status: :unprocessable_entity, json: submission.errors
    end
  end
end