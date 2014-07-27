class Api::V1::WidgetsController < Api::V1::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def update
    if @widget.update_attributes params[:widget]
      render json: @widget.to_json, status: :ok
    else
      render json: @widget.errors, status: :bad_request
    end
  end

  def destroy
    @widget.destroy

    render status: :ok, text: ''
  end
end