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
  before_filter :authenticate_user_from_token!
  # before_filter :authenticate_user!
  before_filter :set_new_user_session
  before_filter :store_location_before
  after_filter :store_location_after
  after_filter :track_landing_page
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
      redirect_to new_user_session_url
    end
  end

  def not_found
    render_404 ActiveRecord::RecordNotFound.new
  end

  # Stores the user's current page to reuse when needed.
  # Excludes all pages that a user shouldn't be redirected to.
  def store_location cookie_name
#    logger.info 'controller: ' + params[:controller].to_s
#    logger.info 'action: ' + params[:action].to_s
    session[cookie_name] = request.url unless params[:controller] == 'users/sessions' || params[:controller] == 'users/registrations' || params[:controller] == 'users/confirmations' || params[:controller] == 'users/omniauth_callbacks' || params[:controller] == 'users/facebook_connections' || params[:controller] == 'users/invitations' || params[:controller] == 'users/authorizations' || params[:controller] == 'devise/passwords' || params[:action] == 'after_registration' || request.method_symbol != :get || request.format != 'text/html'
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
    def allow_iframe
      response.headers.except! 'X-Frame-Options'
    end

    def authenticate_user_from_token!
      user_email = params[:user_email].presence
      user = user_email && User.find_by_email(user_email)

      if user && Devise.secure_compare(user.authentication_token, params[:user_token])
        sign_in user#, store: false
        flash.keep
        redirect_to request.path and return
      end
    end

    def current_ability
      current_user ? current_user.ability : User.new.ability
    end

    def load_assignment
      sql = "SELECT assignments.* FROM assignments INNER JOIN groups ON groups.id = assignments.promotion_id AND groups.type = 'Promotion' INNER JOIN groups courses_groups ON courses_groups.id = groups.parent_id AND courses_groups.type IN ('Course') WHERE groups.type IN ('Promotion') AND groups.user_name = ? AND courses_groups.user_name = ? AND assignments.id_for_promotion = ? ORDER BY assignments.id ASC LIMIT 1"
      @assignment = Assignment.find_by_sql([sql, params[:promotion_name], params[:user_name], params[:id] || params[:assignment_id]]).first
      raise ActiveRecord::RecordNotFound unless @assignment
      @promotion = @assignment.promotion
      @assignment
    end

    def load_event
      @event = Event.includes(:hackathon).where(groups: { user_name: params[:event_name] }, hackathons_groups: { user_name: params[:user_name] }).first!
    end

    def load_project
      return @project if @project
      user_name = params[:user_name] if params[:project_slug] and params[:user_name]

      @project = if user_name
        # find by slug history and redirect to newer url if ever
        project_slug = "#{params[:user_name]}/#{params[:project_slug]}".downcase
        project = Project.includes(:slug_histories).where(slug_histories: { value: project_slug }).first!
        if project.uri != project_slug
          redirect_to(url_for(project), status: 301) and return
        end
        project
      elsif params[:project_slug]
        Project.where(projects: { slug: params[:project_slug].downcase }).first!
      else
        Project.find params[:project_id] || params[:id]
      end
    end

    def load_team
      @team ||= load_with_user_name Team
    end

    def load_user
      @user ||= load_with_slug
    end

    def load_with_user_name model
      model.find_by_user_name!(params[:user_name].downcase)
    end

    def load_with_slug
      slug = SlugHistory.find_by_value!(params[:slug].downcase)
      slug.sluggable
    end

    def track_alias user=nil
      old_distinct_id = current_mixpanel_user
      new_distinct_id = set_current_mixpanel_user(user)
      tracker.enqueue 'alias_user', new_distinct_id, old_distinct_id if tracking_activated?
    end

    def track_event event_name, properties={}, user=nil
      properties.merge! signed_in: !!user_signed_in?
      properties.merge! ref: params[:ref] if params[:ref]
      tracker.enqueue 'record_event', event_name, current_mixpanel_user(user), properties if tracking_activated?
    end

    def track_user properties, user=nil
      tracker.enqueue 'update_user', current_mixpanel_user(user), properties.merge({ ip: request.ip }) if tracking_activated?
    end

    def distinct_id_for user=nil
      user ? "user_#{user.id}" : (request.session_options[:id].present? ? "session_#{request.session_options[:id]}" : nil)
    end

    def current_mixpanel_user user=nil
      cookies[:mixpanel_user] ||= set_current_mixpanel_user(user)
    end

    def set_current_mixpanel_user user=nil
      cookies[:mixpanel_user] = distinct_id_for(user || current_user)
    end

    def reset_current_mixpanel_user
      cookies[:mixpanel_user] = distinct_id_for nil
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
          # 'rack.session' => request.env['rack.session'],
          'mixpanel_events' => request.env['mixpanel_events'],
        }
      }
    end

    def track_landing_page
      return if cookies[:landing_page] and cookies[:initial_referrer]
      cookies[:landing_page] = request.path unless cookies[:landing_page]
      cookies[:initial_referrer] = (request.referrer || 'unknown') unless cookies[:initial_referrer]
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
        message = "#{exception.inspect} // backtrace: #{clean_backtrace.join(' - ')} // user: #{current_user.try(:user_name)} // request_url: #{request.url} // referrer: #{request.referrer} // request_params: #{request.params.to_s} // user_agent #{request.headers['HTTP_USER_AGENT']} // ip: #{request.remote_ip} // format: #{request.format} // HTTP_X_REQUESTED_WITH: #{request.headers['HTTP_X_REQUESTED_WITH']}"
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

    def set_project_mode
      @mode = 'editing'
    end

    def set_new_user_session
      @new_user_session = User.new unless user_signed_in?
    end

    def user_signed_in?
      current_user and current_user.id
    end

  protected
    def impressionist_async obj, message, opts
      ImpressionistQueue.perform_async 'count', { "action_dispatch.remote_ip" => request.remote_ip, "HTTP_REFERER" => request.referer, 'HTTP_USER_AGENT' => request.user_agent, session_hash: request.session_options[:id] }, action_name, controller_name, params, obj.id, obj.class.to_s, message, opts
    end

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

      incoming and !user_signed_in? and (params[:controller].in? %w(projects users teches)) and params[:action] == 'show'
    rescue
      false
    end

    def show_profile_needs_care?
      user_signed_in? and !(params[:controller] == 'users' and params[:action] == 'after_registration') and current_user.profile_needs_care? and current_user.receive_notification?('1311complete_profile')
    end
end
