class ApplicationController < BaseController
  include SocialLinkHelper

  include Rewardino::ControllerExtension

  BOGUS_REQUEST_FORMATS = ['*/*;', '/;', 'hc/url;*/*']
  DEFAULT_RESPONSE_FORMAT = :html
  MOBILE_USER_AGENTS =
    'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
    'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
    'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
    'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
    'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
    'mobile'

  protect_from_forgery except: [:not_found]
  before_action :current_site
  before_action :current_platform
  # before_action :force_ssl_redirect, if: :ssl_configured?  # needs to know about current_site
  before_filter :authenticate_user_from_token!
  before_filter :ensure_valid_path_prefix
  before_action :set_locale, except: [:not_found]
  before_filter :ensure_logged_in
  before_filter :mark_last_seen!, if: proc{|c| c.request.xhr? }
  before_filter :store_location_before
  before_filter :track_visitor
  before_filter :check_new_badge
  before_filter :show_badge
  prepend_after_filter :show_badge
  prepend_after_filter :check_share_modal_after_action
  append_before_filter :check_share_modal_after_redirect
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
  helper_method :api_host
  helper_method :site_user_name
  before_filter :set_signed_in_cookie
  before_filter :set_default_response_format

  helper BootstrapFlashHelper

  # code to make whitelabel work
  helper_method :current_site
  helper_method :current_platform
  helper_method :current_layout
  before_filter :set_view_paths
  layout :current_layout

  # hoping that putting it here will only make the condition run once when the
  # app loads and not on every request
  if ENV['SITE_USERNAME'] and ENV['SITE_PASSWORD']
    before_filter :authorize_site_access!
  end

  def authorize_site_access!
    authorize_access! ENV['SITE_USERNAME'], ENV['SITE_PASSWORD']
  end

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
    return if ENV['CLIENT_SUBDOMAIN'].blank? and (request.host == APP_CONFIG['default_host'] or request.host == api_host)

    return @current_site if @current_site

    redirect_to root_url(subdomain: ENV['SUBDOMAIN'], path_prefix: nil) and return unless @current_site = set_current_site(request.domain, request.subdomains[0], request.host) and @current_site.enabled?
  end

  def current_platform
    return if ENV['CLIENT_SUBDOMAIN'].blank? and (request.host == APP_CONFIG['default_host'] or request.host == api_host)

    return @current_platform if @current_platform

    redirect_to root_url(subdomain: ENV['SUBDOMAIN']) unless @current_platform = current_site.try(:platform)
  end

  def api_host
    return @api_host if @api_host

    return @api_host = ENV['API_HOST'] if ENV['API_HOST'].present?

    @api_host = 'api.'
    if ENV['SUBDOMAIN'].present? and ENV['SUBDOMAIN'] != 'www'
      @api_host += ENV['SUBDOMAIN'] + '.'
    end
    @api_host += APP_CONFIG['default_domain']
    @api_host
  end
  # end code for whitelabel


  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError,
      ActionController::UnknownController,
      AbstractController::ActionNotFound,
      ActiveRecord::RecordNotFound,
      with: :render_404
    rescue_from ActionView::MissingTemplate, with: :render_404_with_log
  end

  rescue_from CanCan::AccessDenied, Workflow::NoTransitionAllowed do |exception|
    if current_user
      if request.xhr?
        render status: :unauthorized, json: { message: "You are not authorized to perform this action." }
      else
        set_flash_message :alert, exception.message
        redirect_to session[request.host].try(:[], :user_return_to_if_disallowed).presence || root_url
      end
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
      path = request.fullpath
      session[request.host] ||= {}
      session[request.host][cookie_name] = path
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
      base_uri = "#{request.scheme}://#{host}"
      base_uri += ":#{APP_CONFIG['default_port']}" if APP_CONFIG['port_required']
      if params[:redirect_to].present?
        "#{base_uri}#{params[:redirect_to]}"
      elsif return_to = session[host].try(:[], :user_return_to).presence
        "#{base_uri}#{return_to}"
      else
        root_url(host: host)
      end
    else
      params[:redirect_to].presence || session[request.host].try(:[], :user_return_to).presence || root_path
    end
  end

  private
    def authorize_access! username, password
      headers['X-Password-Protected'] = 'true'

      site_username = params[:site_username].presence || session[:site_username]
      site_password = params[:site_password].presence || session[:site_password]

      unless site_username == username && site_password == password
        if cookies[:site_username] == username && cookies[:site_password] == password
          session[:site_username] = cookies[:site_username]
          session[:site_password] = cookies[:site_password]
        else
          path = request.fullpath
          redirect_to site_login_path(redirect_to: path)
        end
      end
    end

    def allow_iframe
      response.headers.except! 'X-Frame-Options'
    end

    def authenticate_user_from_token!
      if user = find_user_and_validate_auth_token(params[:user_email], params[:user_token])
        cookies[:hackster_user_signed_in] = '1'
        sign_in user#, store: false
        flash.keep
        path = UrlParam.new(request.fullpath).remove_params(%w(user_token user_email))
        redirect_to path and return
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

    def check_share_modal_after_redirect
      check_share_modal if session[:share_modal_time] == 'after_redirect'
    end

    def check_share_modal_after_action
      check_share_modal if session[:share_modal_time].nil? or session[:share_modal_time] == 'after_action'
    end

    def check_share_modal
      session.delete(:share_modal_time)
      if name = session.delete(:share_modal) and model_type = session.delete(:share_modal_model)
        model = instance_variable_get("@#{model_type}")
        model ||= model_type.camelize.constantize.find_by_id(session.delete(:share_modal_model_id)) if session[:share_modal_model_id]
        return unless model
        model = model.decorate if model.respond_to? :decorate
        @modal = render_to_string(partial: "shared/modals/#{name}", locals: { :"#{model_type}" => model }, formats: [:html])
        # raise @modal.inspect
        if request.xhr? or session.delete(:share_modal_xhr)
          response.headers['X-Alert'] = @modal.gsub(/\n/, '')  # cleanup otherwise line breaks create multiple lines
          response.headers['X-Alert-ID'] = "##{name}"
        end
      end
    end

    def controller_action
      "#{controller_path}##{action_name}"
    end

    def ensure_valid_path_prefix
      not_found unless path_prefix_valid?(params[:path_prefix])
    end

    def show_badge
      if user_signed_in? and @new_badge and @badge_level
        @modal = render_to_string(partial: 'shared/modals/badge_alert', locals: { badge: @new_badge, level: @badge_level })
        if request.xhr?
          response.headers['X-Alert'] = @modal
          response.headers['X-Alert-ID'] = '#badge-alert'
        end
      end
    rescue ActionView::MissingTemplate  # sometimes badges are shown on non-html pages
    end

    def current_ability
      current_user ? current_user.ability : User.new.ability
    end

    def disable_flash
      @no_flash = true
    end

    def ensure_logged_in
      if is_whitelabel? and request.host == current_site.host and current_site.force_login?
        redirect_to new_user_session_path, notice: "Please log in to access #{current_site.name}" and return unless user_signed_in? or request.path == new_user_session_path or request.path == new_user_registration_path
      end
    end

    def find_user_and_validate_auth_token email, token
      return if email.blank? or token.blank?

      user = User.find_by_email(email)
      user if user and Devise.secure_compare(user.authentication_token, token)
    end

    def flash_disabled?
      !!@no_flash
    end

    def is_trackable_page?
      @is_trackable_page ||= (%w(users/sessions users/registrations users/confirmations users/omniauth_callbacks users/facebook_connections users/invitations users/authorizations devise/passwords split application).exclude?(params[:controller]) and !params[:action].in? %w(after_registration toolbox toolbox_save) and request.method_symbol == :get and request.format == 'text/html')
    end

    def load_assignment
      sql = "SELECT assignments.* FROM assignments INNER JOIN groups ON groups.id = assignments.promotion_id AND groups.type = 'Promotion' INNER JOIN groups courses_groups ON courses_groups.id = groups.parent_id AND courses_groups.type IN ('Course') WHERE groups.type IN ('Promotion') AND groups.user_name = ? AND courses_groups.user_name = ? AND assignments.id_for_promotion = ? ORDER BY assignments.id ASC LIMIT 1"
      @assignment = Assignment.find_by_sql([sql, params[:promotion_name], params[:user_name], params[:id] || params[:assignment_id]]).first
      raise ActiveRecord::RecordNotFound unless @assignment
      @group = @promotion = @assignment.promotion
      @assignment
    end

    def load_event
      @group = @event = Event.includes(:hackathon).where(groups: { user_name: params[:event_name] }, hackathons_groups: { user_name: params[:user_name] }).first!
    end

    def load_live_event
      @group = @event = LiveEvent.includes(:live_chapter).where(groups: { user_name: params[:live_event_name] }, live_chapters_groups: { user_name: params[:user_name] }).first!
    end

    def load_project
      return @project if @project
      user_name = params[:user_name] if params[:project_slug] and params[:user_name]

      @project = if user_name
        # find by slug history and redirect to newer url if ever
        project_slug = "#{params[:user_name]}/#{params[:project_slug]}"
        project = BaseArticle.includes(:slug_histories).references(:slug_histories).where("LOWER(slug_histories.value) = ?", project_slug.downcase).first!
        unless self.action_name == 'embed'
          redirect_to(url_for(project), status: 301) and return
        end
        project
      elsif params[:project_slug]
        BaseArticle.where(projects: { slug: params[:project_slug].downcase }).first!
      else
        BaseArticle.find params[:project_id] || params[:id]
      end
    end

    def load_project_with_hid
      return @project if @project

      return not_found unless params[:project_slug].present?

      hid = params[:project_slug].match /-?([a-f0-9]{6})\Z/

      if hid and @project = BaseArticle.find_by_hid(hid[1])
        project_slug = "#{params[:user_name]}/#{params[:project_slug]}"
        if @project.uri != project_slug and !request.xhr?
          redirect_to @project and return
        end
      else
        load_project
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

    def ensure_project_belongs_to_platform
      if is_whitelabel?
        if (!ProjectCollection.where(collectable: current_platform, project: @project).exists? or @project.users.reject{|u| u.enable_sharing }.any?) and !(current_user.try(:is?, :admin) or current_user.try(:id).in?(@project.users.pluck('users.id')))
          raise ActiveRecord::RecordNotFound
        end
      end
    end

    def path_prefix_valid? path_prefix
      # path always valid when not a whitelabel or isn't configured with a prefix
      if is_whitelabel? and (ENV['CLIENT_SUBDOMAIN'].present? or request.host == current_site.host) and current_site.has_path_prefix?
        current_site.path_prefix == path_prefix
      else
        path_prefix.blank?
      end
    end

    def returning_user?
      cookies[:visits].present? and JSON.parse(cookies[:visits]).size > 1
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

      # unless cookies[:next_show_banner].present?
      #   value = if cookies[:last_shown_banner].present?
      #     cookies[:last_shown_banner].to_time + 3.days
      #   elsif cookies[:first_seen].present?
      #     cookies[:first_seen].to_time + 3.days
      #   else
      #     3.days.from_now
      #   end
      #   cookies[:next_show_banner] = { value: value, expires: 10.years.from_now }
      # end

      cookies[:first_seen] = { value: Time.now, expires: 10.years.from_now } unless cookies[:first_seen].present?

      return unless is_trackable_page?
      # if cookies[:next_show_banner].present? and cookies[:next_show_banner].to_time < Time.now
      #   # cookies[:first_seen].to_time < 3.days.ago and (cookies[:last_shown_banner].nil? or cookies[:last_shown_banner].to_time < 3.days.ago)
      #   @modal = render_to_string partial: 'shared/modals/signup_popup'
      #   cookies[:last_shown_banner] = { value: Time.now, expires: 10.years.from_now }
      #   cookies[:next_show_banner] = 3.days.from_now
      #   if cookies[:shown_banner_count].present?
      #     cookies[:shown_banner_count] = cookies[:shown_banner_count].to_i + 1
      #   else
      #     cookies[:shown_banner_count] = { value: 1, expires: 10.years.from_now }
      #   end
      #   data = {
      #     first_seen: cookies[:first_seen],
      #     initial_referrer: cookies[:initial_referrer],
      #     landing_page: cookies[:landing_page],
      #     shown_banner_count: cookies[:shown_banner_count],
      #     visits_count_before_signup: JSON.parse(cookies[:visits]).size,
      #   }
      #   track_event 'Shown signup popup', data
      # end
    end

    def require_no_authentication
      redirect_to root_path, alert: "You're already signed in." if current_user
    end

    def render_404(exception)
      @exception = exception
      @backtrace = Rails.backtrace_cleaner.clean(exception.backtrace) if exception.backtrace
      respond_to do |format|
        format.html { render template: 'errors/error_404', layout: "layouts/#{current_layout}", status: 404 }
        format.all { render nothing: true, status: 404 }
      end
    end

    def render_404_with_log(exception)
      log_error exception
      render_404 exception
    end

    def render_500(exception)
      @exception = exception
      @backtrace = Rails.backtrace_cleaner.clean(exception.backtrace) if exception.backtrace

      # hack because format.all doesn't work anymore
      if exception.class == ActionController::UnknownFormat
        render nothing: true, status: 404 and return
      end

      begin
        unless exception.class.name == 'Sidekiq::Shutdown'
          log_error exception
        end
      rescue
      end
      @error = exception
      respond_to do |format|
        format.html { render template: 'errors/error_500', layout: "layouts/#{current_layout}", status: 500 }
        format.all { render nothing: true, status: 500}
      end
    end

    def log_error exception
      message = "user: #{current_user.try(:user_name)} // request_url: #{request.url} // referrer: #{request.referrer} // request_params: #{request.params.to_s} // user_agent #{request.headers['HTTP_USER_AGENT']} // ip: #{request.remote_ip} // format: #{request.format} // HTTP_X_REQUESTED_WITH: #{request.headers['HTTP_X_REQUESTED_WITH']}"
      AppLogger.new(message, 'error', 'controller', exception).log_and_notify_with_stdout
    end

    def set_default_response_format
      request.format = DEFAULT_RESPONSE_FORMAT if request.format.in? BOGUS_REQUEST_FORMATS
    end

    def set_flash_message type, message
      flash[type] = message
    end

    def set_locale
      I18n.locale = params[:locale].presence || I18n.default_locale

      if is_whitelabel? and current_site.try(:enable_localization?)
       if !I18n.locale.to_s.in?(current_site.active_locales) or (params[:locale].blank? and current_site.force_explicit_locale?)
          redirect_to path_for_default_locale
        end
      elsif params[:locale]
        redirect_to path_for_default_locale ''
      # elsif !I18n.locale.in? I18n.active_locales
      #   redirect_to path_for_default_locale
      end

      I18n.locale = params[:locale].presence || I18n.default_locale
      I18n.short_locale = I18n.locale[0..1]  # two-letter version
    rescue I18n::InvalidLocale
      locale = nil
      if params[:locale].try(:size) == 5
        locale = params[:locale][0..2] + params[:locale][3..4].upcase
        begin
          I18n.locale = locale
        rescue
          locale = nil
        end unless locale == params[:locale]
      end

      redirect_to path_for_default_locale locale
    end

    def path_for_default_locale locale=nil
      default_locale = locale || current_site.try(:default_locale) || I18n.default_locale
      pathes = request.path.split(/\//).select{|a| a.present? }
      pathes.shift if params[:locale].present?
      pathes.unshift default_locale
      path = pathes.select{|v| v.present? }.join('/')
      "/#{path}"
    end

    def site_platform
      is_whitelabel? ? current_platform.user_name : 'hackster'
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
        @meta_desc || "#{SLOGAN} Share your projects and learn from other developers. Come build awesome hardware!"
      end
    end

    def site_name
      is_whitelabel? ? current_site.name : 'Hackster.io'
    end

    def site_user_name
      is_whitelabel? ? current_platform.user_name : 'hackster'
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

    def set_view_paths
      prepend_view_path "app/views/whitelabel/#{site_user_name}" if is_whitelabel?
    end

    def show_hello_world?
      # incoming = request.referer.present? ? URI(request.referer).host != APP_CONFIG['default_host'] : true

      # incoming and
      # removed to allow http caching: checking for referrer in the browser directly
      !user_signed_in? and (params[:controller].in? %w(projects users platforms parts)) and params[:action] == 'show' or @show_hello_world
    rescue
      false
    end

    def show_profile_needs_care?
      user_signed_in? and !(params[:controller] == 'users' and params[:action] == 'after_registration') and current_user.profile_needs_care? and current_user.receive_notification?('1311complete_profile')
    end
end
