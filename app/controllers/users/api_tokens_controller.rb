class Users::ApiTokensController < ActionController::Base
  SCOPE = Doorkeeper.configuration.scopes.to_s  # all

  # this should only be used by www.hackster.io, not an external website
  def show
    tokens = { client_token: client_token.token }

    tokens[:user_token] = user_token.token if user_signed_in?

    render json: tokens
  end

  private
    def client_token
      find_or_create_token
    end

    def find_or_create_token user=nil
      Doorkeeper::AccessToken.find_or_create_for(DOORKEEPER_APP_ID, user.try(:id), SCOPE, JWT_EXPIRES_IN, false)
    end

    def user_token
      find_or_create_token current_user
    end
end