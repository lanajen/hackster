class Api::V1::PagesController < Api::V1::BaseController
  def csrf
    render json: form_authenticity_token
  end
end