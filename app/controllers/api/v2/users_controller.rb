class Api::V2::UsersController < Api::V2::BaseController
  before_action -> { doorkeeper_authorize! :profile }, only: :me

  def me
    render json: {
      id: current_user.id,
      email: current_user.email,
      name: current_user.full_name,
      user_name: current_user.user_name,
      image: current_user.avatar.try(:imgix_url, :big)
    }
  end
end