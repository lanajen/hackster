class Client::BaseController < ApplicationController
  helper_method :current_platform
  helper_method :current_tech
  before_filter :current_platform
  before_filter :current_tech
  layout 'whitelabel'

  def current_platform
    return @current_site if @current_site

    redirect_to root_url(subdomain: 'www') unless @current_site = ClientSubdomain.find_by_subdomain(request.subdomains[0])
  end

  def current_tech
    return @current_tech if @current_tech

    redirect_to root_url(subdomain: 'www') unless @current_tech = Tech.find_by_user_name(request.subdomains[0])
  end

  protected
    def meta_desc meta_desc=nil
      if meta_desc
        @meta_desc = meta_desc
      else
        @meta_desc || "#{current_tech.mini_resume} Come explore #{current_tech.name} projects!"
      end
    end
end