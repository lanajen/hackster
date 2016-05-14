class Users::ApiTokensController < ActionController::Base
  before_filter :authenticate_user!

  # this should only be used by www.hackster.io, not an external website
  def show
    application_id = nil  # no application is created
    scope = ''  # we don't need one
    access_token = Doorkeeper::AccessToken.find_or_create_for(application_id, current_user.id, scope, JWT_EXPIRES_IN, false)
    render json: { token: access_token.token }
  end
end