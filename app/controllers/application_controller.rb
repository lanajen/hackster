class ApplicationController < ActionController::Base
#  protect_from_forgery
  before_filter :set_new_user_session
  before_filter :store_location_before
#  before_filter :set_json_globals
  after_filter :store_location_after

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  rescue_from CanCan::AccessDenied do |exception|
    if current_user
#      unless current_user.confirmed?
#        set_flash_message :alert, "You need to confirm your email address first. %s" % [eval_text{ link_to 'Resend the confirmation email.', new_user_confirmation_path }]
#      else
        set_flash_message :alert, exception.message
#      end
      redirect_to session[:user_return_to_if_disallowed] || root_url
    else
      message = exception.message + ' Please login to continue.'
      redirect_to new_user_session_url, :alert => message
    end
  end

  # Stores the user's current page to reuse when needed.
  # Excludes all pages that a user shouldn't be redirected to.
  def store_location cookie_name
#    logger.info 'controller: ' + params[:controller].to_s
#    logger.info 'action: ' + params[:action].to_s
    session[cookie_name] = request.url unless params[:controller] == 'devise/sessions' || params[:controller] == 'users/registrations' || params[:controller] == 'users/confirmations' || params[:controller] == 'users/omniauth_callbacks' || params[:controller] == 'users/facebook_connections' || request.method_symbol != :get
#    logger.info 'stored location: ' + session[cookie_name].to_s
  end

  # Stores location after the request has been processed
  def store_location_after
    store_location :user_return_to_if_disallowed
  end

  # Stores location before the request has been processed
  def store_location_before
    store_location :user_return_to
  end

  private
    def current_ability
      current_user ? current_user.ability : User.new.ability
    end

    def find_user
      @user = User.find_by_user_name(params[:user_name])
      raise ActiveRecord::RecordNotFound, 'Not found' unless @user
    end

    def require_no_authentication
      redirect_to root_path, alert: "You're already signed in." if current_user
    end

    def render_404(exception)
#      log_line = LogLine.create(log_type: 'not_found', request_url: request.url)
      respond_to do |format|
        format.html { render template: 'errors/error_404', layout: 'layouts/application', status: 404 }
        format.all { render nothing: true, status: 404 }
      end
    end

    def render_500(exception)
#      log_line = LogLine.create(message: "#{exception.inspect}", log_type: 'error',
#        session_data: session.to_s, request_url: request.url[0..254],
#        request_params: request.params)
#      BaseMailer.enqueue_email 'error_notification', { context_type: :log_line, context_id: log_line.id }
      logger.info "Exception: #{exception.inspect}"
      @error = exception
      respond_to do |format|
        format.html { render template: 'errors/error_500', layout: 'layouts/application', status: 500 }
        format.all { render nothing: true, status: 500}
      end
    end

    def set_flash_message type, message
      flash[type] = message
    end

    def set_json_globals
      unless request.xhr?
        gon.rabl "app/views/users/show.json.rabl", as: "current_user"
      end
    end

    def set_new_user_session
      @new_user_session = User.new unless user_signed_in?
    end
end
