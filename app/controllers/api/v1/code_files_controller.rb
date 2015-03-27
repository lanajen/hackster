class Api::V1::CodeFilesController < Api::V1::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource except: [:create]

  def create
    code_file = CodeFile.read_from_file params[:file]

    render json: code_file.to_json(methods: [:binary, :document_url], only: [:raw_code, :language, :name])
  # rescue
  #   render status: :unprocessable_entity, nothing: true
  end
end