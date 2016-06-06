class CodeFilesController < MainBaseController
  skip_before_filter :track_visitor
  skip_after_filter :track_landing_page
  before_filter :authenticate_user!, only: [:create]

  def create
    code_file = CodeWidget.read_from_file params[:file]
    doc = Document.save_from_file params[:file]

    render json: code_file.to_json.merge(document_id: doc.id)
  end

  def download
    widget = CodeWidget.find params[:id]

    not_found unless widget.raw_code.present?

    send_data widget.raw_code,
      filename: widget.file_name,
      type: widget.mime_type,
      disposition: 'attachment'
  end
end