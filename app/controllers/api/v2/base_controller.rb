class Api::V2::BaseController < Api::BaseController
  protect_from_forgery with: :null_session  # disable CSRF token
  before_action :public_api_methods

  rescue_from ApiForbidden do |exception|
    render status: :forbidden, nothing: true
  end

  private
    def authorize! action, model
      raise ApiForbidden unless current_ability.can? action, model
    end

    def current_user
      @current_user ||= (doorkeeper_token && doorkeeper_token.resource_owner_id ? User.find(doorkeeper_token.resource_owner_id) : nil)
    end

    def doorkeeper_authorize_without_scope!
      if !valid_doorkeeper_token_without_scope?
        doorkeeper_render_error
      end
    end

    def public_api_methods
      headers['Access-Control-Allow-Origin'] = '*'
    end

    def valid_doorkeeper_token_without_scope?
      doorkeeper_token && doorkeeper_token.accessible?
    end
end