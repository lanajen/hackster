class Api::V1::FilesController < Api::V1::BaseController
  def show
    file = Attachment.find params[:id]

    render json: file.to_json
  end
end