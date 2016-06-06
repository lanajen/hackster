class Api::BaseController < ApplicationController
  before_filter :allow_cors_requests
  before_filter :mark_last_seen!

  def cors_preflight_check
    head(:ok)
  end

  private
    def allow_cors_requests
      headers['Access-Control-Allow-Methods'] = %w{GET POST PUT DELETE PATCH OPTIONS}.join(',')
      headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token Authorization Token}.join(',')
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
      @current_site ||= begin
        return unless origin_uri and host = origin_uri.host
        domain = ActionDispatch::Http::URL.extract_domain(host, 1)
        subdomains = ActionDispatch::Http::URL.extract_subdomains(host, 1)
        set_current_site domain, subdomains[0], host
      end
    end

    def current_platform
      @current_platform ||= current_site.try(:platform)
    end

    def host_is_whitelisted? host
      host =~ Regexp.new("#{APP_CONFIG['default_domain']}$") or host.in? WHITELISTED_HOSTS
    end

    def origin_uri
      @origin_uri ||= begin
        referrer = request.referrer.presence || request.headers['HTTP_ORIGIN']  # browsers don't always send the referrer for privacy reasons
        URI.parse(referrer)
      end
    rescue URI::InvalidURIError
    end

    def private_api_methods with_credentials=true
      if origin_uri and host_is_whitelisted?(origin_uri.host)
        allowed_origin = origin_uri.scheme + '://' + origin_uri.host
        allowed_origin << ":#{origin_uri.port}" unless origin_uri.port.to_s.in? %w(80 443)
        headers['Access-Control-Allow-Origin'] = allowed_origin
        custom_private_api_methods if self.respond_to?(:custom_private_api_methods, true)
      else
        render status: :not_found, nothing: true
      end
    end

    def render_404(exception)
      render nothing: true, status: 404
    end

    def render_500(exception)
      super

      render nothing: true, status: 500
    end
end
