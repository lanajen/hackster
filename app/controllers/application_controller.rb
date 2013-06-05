class ApplicationController < ActionController::Base
  protect_from_forgery
#  before_filter :authenticate_user_with_key_or_login!
  before_filter :authenticate_user!
  before_filter :set_new_user_session
  before_filter :store_location_before
  after_filter :store_location_after
  helper_method :title
  helper_method :meta_desc

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from AbstractController::ActionNotFound, with: :render_404
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
    def authenticate_user_with_key_or_login!
      authenticate_user! unless authentify_with_auth_key!
    end

    def authentify_with_auth_key!
      auth_key = params[:auth_key] || session[:auth_key]
      return unless auth_key

      if participant_invite = ParticipantInvite.find_by_auth_key(auth_key)
        if user_signed_in?
          participant_invite.update_attributes accepted: true
          participant_invite.project.privacy_rules.create privatable_user_type: 'User',
            privatable_user_id: current_user.id, private: false
          session.delete(:auth_key)
        else
          @current_user = User.new participant_invite_id: participant_invite.id, auth_key_authentified: true
          session[:auth_key] = auth_key
        end
      end
    end

    def current_ability
      current_user ? current_user.ability : User.new.ability
    end

    def find_user
      @user = User.find_by_user_name(params[:user_name])
      raise ActiveRecord::RecordNotFound, 'Not found' unless @user
    end

    def load_project
      @project ||= Project.find params[:project_id] || params[:id]
    end

    def load_and_authorize_project
      load_project
      authorize! :update, @project
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
      begin
        clean_backtrace = Rails.backtrace_cleaner.clean(exception.backtrace)
        message = "#{exception.inspect} // backtrace: #{clean_backtrace.join(' - ')} // session_data: #{session.to_s} // request_url: #{request.url} // request_params: #{request.params.to_s} // user_agent #{request.headers['HTTP_USER_AGENT']} // ip: #{request.remote_ip} // format: #{request.format} // HTTP_X_REQUESTED_WITH: #{request.headers['HTTP_X_REQUESTED_WITH']}"
        log_line = LogLine.create(message: message, log_type: 'error', source: 'controller')
        logger.error ""
        logger.error "Exception: #{exception.inspect}"
        logger.error ""
        clean_backtrace.each { |line| logger.error "Backtrace: " + line }
        logger.error ""
#        BaseMailer.enqueue_email 'error_notification', { context_type: :log_line, context_id: log_line.id }
      rescue
      end
      @error = exception
      respond_to do |format|
        format.html { render template: 'errors/error_500', layout: 'layouts/application', status: 500 }
        format.all { render nothing: true, status: 500}
      end
    end

    def set_flash_message type, message
      flash[type] = message
    end

    def set_new_user_session
      @new_user_session = User.new unless user_signed_in?
    end

    def user_signed_in?
      current_user and current_user.id
    end

  protected
    def meta_desc meta_desc=nil
      if meta_desc
        @meta_desc = meta_desc
      else
        @meta_desc || "Do you hack hardware? Build up your hacker identity all in one place and show the world what you're up to. Request an invite to be part of our early user group!"
      end
    end

    def title title=nil
      if title
        @title = title
      else
        @title ? "#{@title} - Hackster.io" : 'Hackster.io - Your Hacker Profile'
      end
    end
end
