class Api::V2::BaseController < Api::BaseDoorkeeperController
  before_action :public_api_methods

  private
    def public_api_methods
      headers['Access-Control-Allow-Origin'] = '*'
    end
end