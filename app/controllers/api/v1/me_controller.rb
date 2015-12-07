class Api::V1::MeController < Api::V1::BaseController

  def index
    user = {
      id: current_user ? current_user.id : nil,
      isAdmin: current_user ? current_user.is?(:admin) : false,
      csrfToken: form_authenticity_token
    }
    render json: { user: user }
  end

end