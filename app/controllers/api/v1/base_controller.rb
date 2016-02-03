class Api::V1::BaseController < Api::BaseController
  before_filter :public_api_methods

  private
    def public_api_methods
      if request.headers['HTTP_COOKIE'].present?
        private_api_methods
      else
        headers['Access-Control-Allow-Origin'] = '*'
      end
    end
end