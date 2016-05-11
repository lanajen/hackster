class Api::Doorkeeper::UsersController < Api::V1::BaseController
  before_action :doorkeeper_authorize!, only: :me

  def me
    render json: {
      id: current_user.id,
      email: current_user.email,
      name: current_user.full_name,
      user_name: current_user.user_name,
      image: current_user.avatar.try(:imgix_url, :big)
    }
  end

  private
    def current_user
      @current_user ||= User.find(doorkeeper_token.resource_owner_id)
    end
end