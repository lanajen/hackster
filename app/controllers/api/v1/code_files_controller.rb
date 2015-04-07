class Api::V1::CodeFilesController < Api::V1::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource except: [:create]

  def create
    code_file = CodeWidget.read_from_file params[:file]
    doc = Document.save_from_file params[:file]

    render json: code_file.to_json.merge(document_id: doc.id)
  # rescue
  #   render status: :unprocessable_entity, nothing: true
  end
end