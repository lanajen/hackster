class CodeFilesController < ApplicationController
  skip_before_filter :track_visitor
  skip_after_filter :track_landing_page
  before_filter :authenticate_user!

  def create
    code_file = CodeWidget.read_from_file params[:file]
    doc = Document.save_from_file params[:file]

    render json: code_file.to_json.merge(document_id: doc.id)
  end
end