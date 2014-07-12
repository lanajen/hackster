class Api::BaseController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :allow_cors_requests

  def cors_preflight_check
  end

  private
    def allow_cors_requests
      headers['Access-Control-Allow-Methods'] = %w{GET POST PUT DELETE PATCH}.join(',')
      headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(',')
      head(:ok) if request.request_method == 'OPTIONS'
    end

    def public_api_methods
      headers['Access-Control-Allow-Origin'] = '*'
    end
end