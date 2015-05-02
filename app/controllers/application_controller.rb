class ApplicationController < ActionController::Base
  include SocialLinkHelper
  include UrlHelper

  include Rewardino::ControllerExtension

  KNOWN_EVENTS = {
    'hob' => 'Identified as hobbyist',
    'pro' => 'Identified as professional',
  }
  MOBILE_USER_AGENTS =
    'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
    'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
    'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
    'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
    'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
    'mobile'

  protect_from_forgery except: [:not_found]
  before_filter :authenticate_user_from_token!
  before_filter :mark_last_seen!
  before_filter :set_new_user_session
  before_filter :store_location_before
  before_filter :track_visitor
  before_filter :check_new_badge
  before_filter :show_badge
  prepend_after_filter :show_badge
  before_filter :check_share_modal
  prepend_after_filter :check_share_modal
  after_filter :store_location_after
  after_filter :track_landing_page
  helper_method :flash_disabled?
  helper_method :safe_page_params
  helper_method :title
  helper_method :meta_desc
  helper_method :site_name
  helper_method :is_whitelabel?
  helper_method :user_return_to
  helper_method :show_hello_world?
  helper_method :show_profile_needs_care?
  helper_method :is_mobile?
  helper_method :returning_user?
  helper_method :controller_action
  helper_method :is_trackable_page?
  before_filter :set_signed_in_cookie
  helper BootstrapFlashHelper

  # code to make whitelabel work
  helper_method :current_site
  helper_method :current_platform
  before_filter :current_site
  before_filter :current_platform
  helper_method :current_layout
  layout :current_layout

  def set_signed_in_cookie
    if user_signed_in?
      cookies[:hackster_user_signed_in] = '1' if cookies[:hackster_user_signed_in].blank?
    else
      cookies.delete(:hackster_user_signed_in) if cookies[:hackster_user_signed_in].present?
    end
  end

  def current_layout
    @layout ||= if current_site
      'whitelabel'
    else
      'application'
    end
  end

  def current_site
    return if request.host == APP_CONFIG['default_host']

    return @current_site if @current_site

    redirect_to root_url(subdomain: 'www') unless @current_site = if request.domain == APP_CONFIG['default_domain']
      ClientSubdomain.find_by_subdomain(request.subdomains[0])
    else
      ClientSubdomain.find_by_domain(request.host)
    end
  end

  def current_platform
    return if request.host == APP_CONFIG['default_host']

    return @current_platform if @current_platform

    redirect_to root_url(subdomain: 'www') unless @current_platform = current_site.try(:platform)
  end
  # end code for whitelabel


  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError,
      ActionController::UnknownController,
      AbstractController::ActionNotFound,
      ActiveRecord::RecordNotFound,
      with: :render_404
    # rescue_from ActionView::MissingTemplate, with: :render_404_with_error
  end

  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      set_flash_message :alert, exception.message
      redirect_to session[:user_return_to_if_disallowed] || root_url
    else
      redirect_to new_user_session_url
    end
  end

  def not_found
    render_404 ActiveRecord::RecordNotFound.new
  rescue ActionController::InvalidCrossOriginRequest
  end

  # Stores the user's current page to reuse when needed.
  # Excludes all pages that a user shouldn't be redirected to.
  def store_location cookie_name
    # puts 'stored location (before): ' + session[request.host].try(:[], :user_return_to).to_s
    # logger.info 'controller: ' + params[:controller].to_s
    # logger.info 'action: ' + params[:action].to_s
    if is_trackable_page?
      session[request.host] ||= {}
      session[request.host][cookie_name] = request.path
    end
    # puts 'stored location (after): ' + session[request.host].try(:[], :user_return_to).to_s
  end

  # Stores location after the request has been processed
  def store_location_after
    store_location :user_return_to_if_disallowed
  end

  # Stores location before the request has been processed
  def store_location_before
    store_location :user_return_to
  end

  def user_return_to host=nil
    # puts 'params[:redirect_to]: ' + params[:redirect_to].to_s
    # puts 'session[request.host].try(:[], :user_return_to): ' + session[request.host].try(:[], :user_return_to).to_s
    if host
      scheme = APP_CONFIG['use_ssl'] ? 'https://' : 'http://'
      if params[:redirect_to].present?
        "#{scheme}#{host}:#{APP_CONFIG['default_port']}#{params[:redirect_to]}"
      elsif session[request.host].try(:[], :user_return_to).present?
        "#{scheme}#{host}:#{APP_CONFIG['default_port']}#{session[request.host].try(:[], :user_return_to)}"
      else
        root_url(host: host)
      end
    else
      params[:redirect_to].presence || session[request.host].try(:[], :user_return_to).presence || root_path
    end
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

    def check_new_badge
      if session[:new_badge]
        @new_badge = Rewardino::Badge.find session[:new_badge]
        @badge_level = session[:badge_level]
        session.delete :new_badge
        session.delete :badge_level
      end
      # @new_badge = Rewardino::Badge.all.first
      # @badge_level = :bronze
    end

    def check_share_modal
      if session[:share_modal] and name = session.delete(:share_modal) and model = session.delete(:share_modal_model)
        @modal = render_to_string(partial: "shared/modals/#{name}", locals: { :"#{model}" => instance_variable_get("@#{model}") })
        # raise @modal.inspect
        if request.xhr?
          response.headers['X-Alert'] = @modal.gsub(/\n/, '')  # cleanup otherwise line breaks create multiple lines
          response.headers['X-Alert-ID'] = "##{name}"
        end
      end
    end

    def controller_action
      "#{controller_path}##{action_name}"
    end

    def show_badge
      if @new_badge and @badge_level
        @modal = render_to_string(partial: 'shared/modals/badge_alert', locals: { badge: @new_badge, level: @badge_level })
        if request.xhr?
          response.headers['X-Alert'] = @modal
          response.headers['X-Alert-ID'] = '#badge-alert'
        end
      end
    end

    def current_ability
      current_user ? current_user.ability : User.new.ability
    end

    def disable_flash
      @no_flash = true
    end

    def flash_disabled?
      !!@no_flash
    end

    def is_trackable_page?
      @is_trackable_page ||= (%w(users/sessions users/registrations users/confirmations users/omniauth_callbacks users/facebook_connections users/invitations users/authorizations devise/passwords split application).exclude?(params[:controller]) and params[:action] != 'after_registration' and request.method_symbol == :get and request.format == 'text/html')
    end

    def load_assignment
      sql = "SELECT assignments.* FROM assignments INNER JOIN groups ON groups.id = assignments.promotion_id AND groups.type = 'Promotion' INNER JOIN groups courses_groups ON courses_groups.id = groups.parent_id AND courses_groups.type IN ('Course') WHERE groups.type IN ('Promotion') AND groups.user_name = ? AND courses_groups.user_name = ? AND assignments.id_for_promotion = ? ORDER BY assignments.id ASC LIMIT 1"
      @assignment = Assignment.find_by_sql([sql, params[:promotion_name], params[:user_name], params[:id] || params[:assignment_id]]).first
      raise ActiveRecord::RecordNotFound unless @assignment
      @promotion = @assignment.promotion
      @assignment
    end

    def load_event
      @group = @event = Event.includes(:hackathon).where(groups: { user_name: params[:event_name] }, hackathons_groups: { user_name: params[:user_name] }).first!
    end

    def load_project
      return @project if @project
      user_name = params[:user_name] if params[:project_slug] and params[:user_name]

      @project = if user_name
        # find by slug history and redirect to newer url if ever
        project_slug = "#{params[:user_name]}/#{params[:project_slug]}"
        project = Project.includes(:slug_histories).references(:slug_histories).where("LOWER(slug_histories.value) = ?", project_slug.downcase).first!
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

    def mark_last_seen!
      TrackerQueue.perform_async 'mark_last_seen', current_user.id, Time.now.to_i, "#{controller_path}##{self.action_name}" if user_signed_in?
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

    def returning_user?
      cookies[:visits].present? and JSON.parse(cookies[:visits]).size > 1
    end

    def tracking_activated?
      Rails.env == 'production' and !current_user.try(:is?, :admin) and !(request.user_agent.present? and '23.0.1271.97'.in? request.user_agent)
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

    def track_signup resource, simplified=false
      # time_since_shown_signup_popup = cookies[:last_shown_banner].present? ? (Time.now - cookies[:last_shown_banner].to_time) : 'never'
      data = {
        # first_seen: cookies[:first_seen],
        initial_referrer: cookies[:initial_referrer],
        landing_page: cookies[:landing_page],
        # shown_banner_count: cookies[:shown_banner_count],
        # visits_count_before_signup: JSON.parse(cookies[:visits]).size,
        simplified: simplified,
        source: params[:source],
        platform: site_platform,
      }

      track_alias
      track_user resource.to_tracker_profile.merge(data)
      # track_event 'Signed up', data.merge({ time_since_shown_signup_popup: time_since_shown_signup_popup })
      track_event 'Signed up', data

      cookies.delete(:first_seen)
      cookies.delete(:last_shown_banner)
      cookies.delete(:shown_banner_count)
      cookies.delete(:next_show_banner)
    end

    def track_visitor
      if params[:t] and params[:t].in? KNOWN_EVENTS.keys
        track_event KNOWN_EVENTS[params[:t]]
      end

      cookies[:visits] = { value: {}.to_json, expires: 10.years.from_now } unless cookies[:visits].present?
      begin
        visits = JSON.parse cookies[:visits]
      rescue
        visits = cookies[:visits] = { value: {}.to_json, expires: 10.years.from_now }  # so that corrupt cookies don't make an error
      end

      if visits[Date.today.to_s].present?
        visits[Date.today.to_s] = visits[Date.today.to_s].to_i + 1
      else
        track_event 'Registered user visited', { logged_in: user_signed_in? } if user_signed_in? or cookies[:member]
        visits[Date.today.to_s] = 1
      end
      cookies[:visits] = visits.to_json

      if user_signed_in? or cookies[:member]
        cookies[:member] = { value: true, expires: 10.years.from_now }
        return
      end

      unless cookies[:next_show_banner].present?
        value = if cookies[:last_shown_banner].present?
          cookies[:last_shown_banner].to_time + 3.days
        elsif cookies[:first_seen].present?
          cookies[:first_seen].to_time + 3.days
        else
          3.days.from_now
        end
        cookies[:next_show_banner] = { value: value, expires: 10.years.from_now }
      end

      cookies[:first_seen] = { value: Time.now, expires: 10.years.from_now } unless cookies[:first_seen].present?

      return unless is_trackable_page?
      if cookies[:next_show_banner].to_time < Time.now
        # cookies[:first_seen].to_time < 3.days.ago and (cookies[:last_shown_banner].nil? or cookies[:last_shown_banner].to_time < 3.days.ago)
        @modal = render_to_string partial: 'shared/modals/signup_popup'
        cookies[:last_shown_banner] = { value: Time.now, expires: 10.years.from_now }
        cookies[:next_show_banner] = 3.days.from_now
        if cookies[:shown_banner_count].present?
          cookies[:shown_banner_count] = cookies[:shown_banner_count].to_i + 1
        else
          cookies[:shown_banner_count] = { value: 1, expires: 10.years.from_now }
        end
        data = {
          first_seen: cookies[:first_seen],
          initial_referrer: cookies[:initial_referrer],
          landing_page: cookies[:landing_page],
          shown_banner_count: cookies[:shown_banner_count],
          visits_count_before_signup: JSON.parse(cookies[:visits]).size,
        }
        track_event 'Shown signup popup', data
      end
    end

    def require_no_authentication
      redirect_to root_path, alert: "You're already signed in." if current_user
    end

    def render_404(exception)
      # LogLine.create(log_type: 'not_found', source: 'controller', message: request.url) unless request.url =~ /users\/auth\/[a-z]+\/callback/
      respond_to do |format|
        format.html { render template: 'errors/error_404', layout: "layouts/#{current_layout}", status: 404 }
        format.all { render nothing: true, status: 404 }
      end
    end

    def render_500(exception)
      # hack because format.all doesn't work anymore
      if exception.class == ActionController::UnknownFormat
        render nothing: true, status: 404 and return
      end

      begin
        clean_backtrace = Rails.backtrace_cleaner.clean(exception.backtrace)
        message = "#{exception.inspect} // backtrace: #{clean_backtrace.join(' - ')} // user: #{current_user.try(:user_name)} // request_url: #{request.url} // referrer: #{request.referrer} // request_params: #{request.params.to_s} // user_agent #{request.headers['HTTP_USER_AGENT']} // ip: #{request.remote_ip} // format: #{request.format} // HTTP_X_REQUESTED_WITH: #{request.headers['HTTP_X_REQUESTED_WITH']}"
        log_line = LogLine.create(message: message, log_type: 'error', source: 'controller')
        logger.error ""
        logger.error "Exception: #{exception.inspect}"
        logger.error ""
        clean_backtrace.each { |line| logger.error "Backtrace: " + line }
        logger.error ""
        NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification' if Rails.env == 'production'
      rescue
      end
      @error = exception
      respond_to do |format|
        format.html { render template: 'errors/error_500', layout: "layouts/#{current_layout}", status: 500 }
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

    def site_platform
      is_whitelabel? ? current_platform.user_name : 'hackster'
    end

    def ssl_configured?
      Rails.env == 'production'
    end

    def user_signed_in?
      current_user and current_user.id
    end

  protected
    def impressionist_async obj, message, opts
      if obj.kind_of? Hash
        obj_id = obj[:id]
        obj_type = obj[:type]
      else
        obj_id = obj.id
        obj_type = obj.class.to_s
      end
      ImpressionistQueue.perform_async 'count', { "action_dispatch.remote_ip" => request.remote_ip, "HTTP_REFERER" => (opts.delete(:referrer).presence || request.referer), 'HTTP_USER_AGENT' => request.user_agent, session_hash: (request.session_options[:id].presence || SecureRandom.hex(16)) }, (opts.delete(:action_name).presence || action_name), (opts.delete(:controller_name).presence || controller_name), params, obj_id, obj_type, message, opts
    rescue
    end

    def is_mobile?
      request.user_agent.to_s.downcase =~ Regexp.new(MOBILE_USER_AGENTS)
    end

    def is_whitelabel?
      current_site.present?
    end

    def meta_desc meta_desc=nil
      if meta_desc
        @meta_desc = meta_desc
      else
        @meta_desc || "#{SLOGAN} Share your projects and learn from other makers. Come build awesome hardware!"
      end
    end

    def site_name
      is_whitelabel? ? current_site.name : 'Hackster.io'
    end

    def title title=nil
      if title
        @title = title
      else
        if is_whitelabel?
          @title ? "#{@title} - #{site_name}" : site_name
        else
          @title ? "#{@title} - #{site_name}" : "#{site_name} - #{SLOGAN_NO_BRAND}"
        end
      end
    end

    def safe_page_params
      return nil unless params[:page]

      Integer params[:page]
    rescue
      raise ActiveRecord::RecordNotFound
    end

    def show_hello_world?
      # incoming = request.referer.present? ? URI(request.referer).host != APP_CONFIG['default_host'] : true

      # incoming and
      # removed to allow http caching: checking for referrer in the browser directly
      !user_signed_in? and (params[:controller].in? %w(projects users platforms)) and params[:action] == 'show'
    rescue
      false
    end

    def show_profile_needs_care?
      user_signed_in? and !(params[:controller] == 'users' and params[:action] == 'after_registration') and current_user.profile_needs_care? and current_user.receive_notification?('1311complete_profile')
    end
end
