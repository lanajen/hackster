class Api::Private::ChallengesController < Api::Private::BaseController
  before_filter :load_challenge

  def entries_csv
    generate_response 'entries', 'generate_entries_csv'
  end

  def ideas_csv
    generate_response 'ideas', 'generate_ideas_csv'
  end

  def participants_csv
    generate_response 'participants', 'generate_participants_csv'
  end

  private
    def generate_response label, method_name
      doc = Document.new
      doc.attachable_id = 0
      doc.attachable_type = 'Orphan'

      if doc.save
        file_name = FileNameGenerator.new(@challenge.name, label).to_s + '.csv'
        job_id = ChallengeCriticalWorker.perform_async method_name, @challenge.id, doc.id, file_name
        render json: { job_id: job_id, file_id: doc.id }
      else
        render json: doc.errors, status: :unprocessable_entity
      end
    end

    def load_challenge
      @challenge = Challenge.find params[:challenge_id]
      authorize! :admin, @challenge
    end
end