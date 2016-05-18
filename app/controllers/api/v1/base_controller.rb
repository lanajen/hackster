class Api::V1::BaseController < Api::BaseController
  before_filter :public_api_methods

  private
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
      if request.headers['Authorization'].present? and request.headers['Authorization'] =~ /^Basic/
        authenticate_api_user
      else
        authenticate_user!
      end
    end

    def load_platform username
      @current_platform = Platform.find_by_api_username! username
      @current_ability = @current_platform.ability
      @authenticated_as_platform = true
    end

    def public_api_methods
      headers['Access-Control-Allow-Origin'] = '*'
    end

    def public_or_private_api_methods
      if request.headers['HTTP_COOKIE'].present?
        private_api_methods
      else
        public_api_methods
      end
    end
end