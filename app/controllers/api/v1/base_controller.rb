class Api::V1::BaseController < Api::BaseController
  before_filter :public_api_methods

  private
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