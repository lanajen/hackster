class Api::BaseDoorkeeperController < Api::BaseController
  protect_from_forgery with: :null_session  # disable CSRF token
  before_action :disable_cookies
  skip_before_filter :set_signed_in_cookie

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

    def disable_cookies
      request.session_options[:skip] = true
    end

    def doorkeeper_authorize_without_scope!
      if !valid_doorkeeper_token_without_scope?
        doorkeeper_render_error
      end
    end

    def valid_doorkeeper_token_without_scope?
      doorkeeper_token && doorkeeper_token.accessible?
    end
end