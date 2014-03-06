class Client::BaseController < ApplicationController
  helper_method :current_platform
  layout 'whitelabel'

  def current_platform
    @current_site ||= ClientSubdomain.find_by_subdomain request.subdomains[0]
  end
end