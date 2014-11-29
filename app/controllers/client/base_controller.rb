class Client::BaseController < ApplicationController
  helper_method :current_site
  helper_method :current_platform
  before_filter :current_site
  before_filter :current_platform
  layout 'whitelabel'

  def current_site
    return @current_site if @current_site

    redirect_to root_url(subdomain: 'www') unless @current_site = if request.domain == APP_CONFIG['default_domain']
      ClientSubdomain.find_by_subdomain(request.subdomains[0])
    else
      ClientSubdomain.find_by_domain(request.host)
    end
  end

  def current_platform
    return @current_platform if @current_platform

    redirect_to root_url(subdomain: 'www') unless @current_platform = current_site.platform
  end

  protected
    def meta_desc meta_desc=nil
      if meta_desc
        @meta_desc = meta_desc
      else
        @meta_desc || "#{current_platform.mini_resume} Come explore #{current_platform.name} projects!"
      end
    end
end