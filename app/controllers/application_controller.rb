class ApplicationController < ActionController::Base
  include UrlHelper

  MOBILE_USER_AGENTS =
    'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
    'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
    'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
    'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
    'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
    'mobile'

  protect_from_forgery
  # before_filter :authenticate_user!
  before_filter :set_new_user_session
  before_filter :store_location_before
  after_filter :store_location_after
  helper_method :title
  helper_method :meta_desc
  helper_method :user_return_to
  helper_method :show_hello_world?
  helper_method :show_profile_needs_care?
  helper_method :is_mobile?
  helper BootstrapFlashHelper

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError,
      ActionController::UnknownController,
      AbstractController::ActionNotFound,
      ActiveRecord::RecordNotFound,
      with: :render_404
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
      redirect_to new_user_session_url, notice: 'The page you are trying to access is restricted to logged in users. Please log in to continue.'
    end
  end

  # Stores the user's current page to reuse when needed.
  # Excludes all pages that a user shouldn't be redirected to.
  def store_location cookie_name
#    logger.info 'controller: ' + params[:controller].to_s
#    logger.info 'action: ' + params[:action].to_s
    session[cookie_name] = request.url unless params[:controller] == 'users/sessions' || params[:controller] == 'users/registrations' || params[:controller] == 'users/confirmations' || params[:controller] == 'users/omniauth_callbacks' || params[:controller] == 'users/facebook_connections' || params[:controller] == 'users/invitations' || params[:controller] == 'users/authorizations' || params[:controller] == 'devise/passwords' || params[:action] == 'after_registration' || request.method_symbol != :get
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

  def user_return_to
    params[:redirect_to] || session[:user_return_to] || (user_signed_in? ? current_user : nil) || root_path
  end

  private
    def current_ability
      current_user ? current_user.ability : User.new.ability
    end

    def load_project
      return @project if @project
      user_name = params[:user_name] if params[:project_slug] and params[:user_name] and params[:user_name] != 'non_attributed'

      @project = if user_name
        # find by slug history and redirect to newer url if ever
        project_slug = "#{params[:user_name]}/#{params[:project_slug]}"
        project = Project.joins(:slug_histories).where(slug_histories: { value: project_slug }).first!
        if project.uri != project_slug
          redirect_to(url_for(project), status: 301) and return
        end
        project
        # finds by team or by user and throws a record not found if needed
        # Project.joins(:team).where(groups: { user_name: user_name}).where(projects: { slug: params[:project_slug].downcase }).first || if project = Project.joins(:users).where(users: { user_name: user_name}).where(projects: { slug: params[:project_slug].downcase }).first!
        #     redirect_to(url_for(project), status: 301) and return
        #   end
      elsif params[:project_slug]
        Project.joins(:team).where(groups: { user_name: ['', nil]}).where(projects: { slug: params[:project_slug].downcase }).first!
      else
        Project.find params[:project_id] || params[:id]
      end
    end

    def load_team
      @team ||= load_with_user_name Team
    end

    def load_user
      @user ||= load_with_user_name User
    end

    def load_with_user_name model
      model.find_by_user_name!(params[:user_name].downcase)
    end

    def track_alias user=nil
      # tracker.alias_user (user || current_user)
      tracker.enqueue 'alias_user', (user.try(:id) || current_user.try(:id)), user.class.name if tracking_activated?
    end

    def track_event event_name, properties={}, user=nil
      # tracker.record_event event_name, current_user, properties
      user ||= current_user
      tracker.enqueue 'record_event', event_name, user.try(:id), user.class.name, properties if tracking_activated?
    end

    def track_user properties, user=nil
      # tracker.update_user current_user, properties.merge({ ip: request.ip })
      user ||= current_user
      tracker.enqueue 'update_user', user.try(:id), user.class.name, properties.merge({ ip: request.ip }) if tracking_activated?
    end

    def tracking_activated?
      !(Rails.env == 'production' and current_user.try(:is?, :admin))
    end

    def tracker
      @tracker ||= Tracker.new tracker_options
    end

    def tracker_options
      {
        # env: request.env,
        env: {
          'REMOTE_ADDR' => request.env['REMOTE_ADDR'],
          'HTTP_X_FORWARDED_FOR' => request.env['HTTP_X_FORWARDED_FOR'],
          'rack.session' => request.env['rack.session'],
          'mixpanel_events' => request.env['mixpanel_events'],
        }
      }
    end

    def require_no_authentication
      redirect_to root_path, alert: "You're already signed in." if current_user
    end

    def render_404(exception)
      LogLine.create(log_type: 'not_found', source: 'controller', message: request.url) unless request.url =~ /users\/auth\/[a-z]+\/callback/
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
        BaseMailer.enqueue_email 'error_notification', { context_type: :log_line, context_id: log_line.id }
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
    def is_mobile?
      request.user_agent.to_s.downcase =~ Regexp.new(MOBILE_USER_AGENTS)
    end

    def meta_desc meta_desc=nil
      if meta_desc
        @meta_desc = meta_desc
      else
        @meta_desc || "Do you hack hardware? Show the world what you're up to and get inspiration from other makers. Come join the movement!"
      end
    end

    def title title=nil
      if title
        @title = title
      else
        @title ? "#{@title} - Hackster.io" : "Hackster.io - #{SLOGAN}"
      end
    end

    def show_hello_world?
      incoming = request.referer.present? ? URI(request.referer).host != APP_CONFIG['default_host'] : true

      incoming and !user_signed_in? and (params[:controller] == 'projects' or params[:controller] == 'users') and params[:action] == 'show'
    end

    def show_profile_needs_care?
      user_signed_in? and !(params[:controller] == 'users' and params[:action] == 'after_registration') and current_user.profile_needs_care? and current_user.receive_notification?('1311complete_profile')
    end
end
