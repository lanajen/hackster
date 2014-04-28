class Client::BaseController < ApplicationController
  helper_method :current_platform
  helper_method :current_tech
  layout 'whitelabel'

  def current_platform
    @current_site ||= ClientSubdomain.find_by_subdomain request.subdomains[0]
  end

  def current_tech
    @current_tech ||= Tech.find_by_user_name request.subdomains[0]
  end
end