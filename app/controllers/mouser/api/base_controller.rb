class Mouser::Api::BaseController < ActionController::Base
  before_filter :allow_cors_requests

  def cors_preflight_check
    head(:ok)
  end

  private
    def allow_cors_requests
      headers['Access-Control-Allow-Methods'] = %w{GET POST PUT DELETE PATCH OPTIONS}.join(',')
      headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token Authorization Token}.join(',')
      origin = APP_CONFIG['use_ssl'] ? 'https' : 'http'
      origin << '://'
      origin << 'mousercontest.'
      origin << APP_CONFIG['default_domain']
      origin << ":#{APP_CONFIG['default_port']}" if APP_CONFIG['port_required']
      headers['Access-Control-Allow-Origin'] = origin
    end
end