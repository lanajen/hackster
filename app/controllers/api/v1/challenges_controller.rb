class Api::V1::ChallengesController < Api::V1::BaseController
  before_filter :load_challenge

  def ideas_csv
    doc = Document.new
    doc.attachable_id = 0
    doc.attachable_type = 'Orphan'

    if doc.save
      file_name = FileNameGenerator.new(@challenge.name, 'ideas').to_s + '.csv'
      file_url = File.join(ActionController::Base.asset_host, doc.file.store_dir, file_name)
      job_id = ChallengeWorker.perform_async 'generate_ideas_csv', @challenge.id, doc.id, file_name
      render json: { job_id: job_id, file_url: file_url, file_id: doc.id }
    else
      render json: doc.errors, status: :unprocessable_entity
    end
  end

  def participants_csv
  end

  def projects_csv
  end

  private
    def load_challenge
      @challenge = Challenge.find params[:challenge_id]
      authorize! :admin, @challenge
    end
end