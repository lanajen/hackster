class Api::Private::BaseController < Api::BaseController
  before_filter :private_api_methods

  private
    def custom_private_api_methods
      headers['Access-Control-Allow-Credentials'] = 'true'
      headers['Access-Control-Expose-Headers'] = 'X-Alert,X-Alert-ID'
    end
end