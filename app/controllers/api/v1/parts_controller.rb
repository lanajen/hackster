class Api::V1::PartsController < Api::V1::BaseController
  def create
    part = Part.new params[:part]

    if part.save
      render json: part.to_json
    else
      render status: :unprocessable_entity
    end
  end

  def destroy
    part = Part.find params[:id]
    part.destroy

    render status: :ok, text: ''
  end
end