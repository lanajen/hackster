class Api::BaseController < ApplicationController
  skip_before_filter :authorize_site_access!
  skip_before_filter :track_visitor
  skip_after_filter :track_landing_page
  skip_before_filter :verify_authenticity_token
  skip_before_action :set_locale
  skip_before_filter :ensure_valid_path_prefix
  before_filter :allow_cors_requests

  def cors_preflight_check
    head(:ok)
  end

  private
    def allow_cors_requests
      headers['Access-Control-Allow-Methods'] = %w{GET POST PUT DELETE PATCH OPTIONS}.join(',')
      headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token Authorization Token}.join(',')
    end

    def authenticate_api_user
      if Rails.env == 'development'
        @current_platform = Platform.find_by_user_name('cypress')
        @current_ability = @current_platform.ability
        return
      end

      authenticate_or_request_with_http_basic do |username, password|
        load_platform(username)
        @current_platform && username == @current_platform.api_username && password == @current_platform.api_password
      end
    end

    def authenticated_as_platform?
      current_platform and @authenticated_as_platform
    end

    def authenticate_platform_or_user
      if request.headers['Authorization'].present? or request.headers['Authorization'] =~ /^Basic/
        authenticate_api_user
      else
        # authenticate_user!
        doorkeeper_authorize!
      end
    end

    def current_ability
      if @current_ability
        @current_ability
      elsif current_user
        current_user.ability
      else
        User.new.ability
      end
    end

    def current_site
      return @current_site if @current_site

      return unless origin_uri and host = origin_uri.host
      domain = ActionDispatch::Http::URL.extract_domain(host, 1)
      subdomains = ActionDispatch::Http::URL.extract_subdomains(host, 1)
      @current_site = set_current_site domain, subdomains[0], host
    end

    def current_platform
      return @current_platform if @current_platform

      @current_platform = current_site.try(:platform)
    end

    def origin_uri
      return @origin_uri if @origin_uri
      referrer = request.referrer.presence || request.headers['HTTP_ORIGIN']  # browsers don't always send the referrer for privacy reasons
      @origin_uri = URI.parse(referrer)
    rescue URI::InvalidURIError
    end

    def load_platform username
      @current_platform = Platform.find_by_api_username! username
      @current_ability = @current_platform.ability
      @authenticated_as_platform = true
    end

    def host_is_whitelisted? host
      host =~ Regexp.new("#{APP_CONFIG['default_domain']}$") or host.in? WHITELISTED_HOSTS
    end

    def private_api_methods
      if origin_uri and host_is_whitelisted?(origin_uri.host)
        allowed_origin = origin_uri.scheme + '://' + origin_uri.host
        allowed_origin << ":#{origin_uri.port}" unless origin_uri.port.to_s.in? %w(80 443)
        headers['Access-Control-Allow-Origin'] = allowed_origin
        headers['Access-Control-Allow-Credentials'] = 'true'
        headers['Access-Control-Expose-Headers'] = 'X-Alert,X-Alert-ID'
      else
        render status: :not_found, nothing: true
      end
    end
end