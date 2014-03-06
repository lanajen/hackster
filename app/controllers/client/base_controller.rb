class Client::BaseController < ApplicationController
  helper_method :current_platform

  def current_platform
    @current_site ||= ClientSubdomain.find_by_subdomain request.subdomains[0]
  end
end