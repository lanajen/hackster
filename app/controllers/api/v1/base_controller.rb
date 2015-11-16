class Api::V1::BaseController < ApplicationController
  skip_before_filter :track_visitor
  skip_after_filter :track_landing_page
  skip_before_filter :verify_authenticity_token
  skip_before_action :set_locale
  before_filter :allow_cors_requests
  before_filter :public_api_methods, only: [:cors_preflight_check]

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
        @platform = Platform.find_by_user_name('microsoft')
        return
      end

      authenticate_or_request_with_http_basic do |username, password|
        load_platform(username)
        @platform && username == @platform.api_username && password == @platform.api_password
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
      if current_platform
        current_platform.ability
      elsif current_user
        current_user.ability
      else
        User.new.ability
      end
    end

    def current_platform
      @platform
    end

    def load_platform username
      @platform = Platform.find_by_api_username username
    end

    def public_api_methods
      headers['Access-Control-Allow-Origin'] = '*'
    end
end