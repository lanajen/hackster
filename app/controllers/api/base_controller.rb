class Api::BaseController < ApplicationController
  skip_before_filter :authorize_site_access!
  skip_before_filter :track_visitor
  skip_after_filter :track_landing_page
  skip_before_filter :verify_authenticity_token
  skip_before_action :set_locale
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

    def authenticate_platform_or_user
      if request.headers['Authorization'].present?
        authenticate_api_user
      else
        authenticate_user!
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

    def current_platform
      return @current_platform if @current_platform

      @current_platform = current_site.try(:platform)
    end

    def load_platform username
      @current_platform = Platform.find_by_api_username! username
      @current_ability = @current_platform.ability
    end

    def host_is_whitelisted? host
      host =~ Regexp.new("#{APP_CONFIG['default_domain']}$") or host.in? WHITELISTED_HOSTS
    end

    def private_api_methods
      referrer = request.referrer
      referrer_uri = URI.parse(referrer)
      if host_is_whitelisted?(referrer_uri.host)
        allowed_origin = referrer_uri.scheme + '://' + referrer_uri.host
        allowed_origin << ":#{referrer_uri.port}" if referrer_uri.port != 80
        headers['Access-Control-Allow-Origin'] = allowed_origin
        headers['Access-Control-Allow-Credentials'] = 'true'
      end
    rescue URI::InvalidURIError
    end
end