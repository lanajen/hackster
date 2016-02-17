class SiteLoginsController < ActionController::Base
  layout 'blank'
  helper_method :meta_desc
  helper_method :title

  def new
    render status: :unauthorized
  end

  def create
    next_url = params[:redirect_to] || root_path

    if ENV['SITE_USERNAME'] && ENV['SITE_PASSWORD']
      username = ENV['SITE_USERNAME']
      password = ENV['SITE_PASSWORD']
    else
      current_site = ((request.domain == APP_CONFIG['default_domain'] && ClientSubdomain.find_by_subdomain(request.subdomains[0])) || ClientSubdomain.find_by_domain(request.host))
      if current_site && current_site.enabled? && current_site.platform && current_site.platform.enable_password
        username = current_site.platform.user_name
        password = current_site.platform.http_password
      else
        redirect_to next_url and return
      end
    end

    if params[:site_username] == username && params[:site_password] == password
      session[:site_username] = params[:site_username]
      session[:site_password] = params[:site_password]
      if params[:remember]
        cookies[:site_username] = params[:site_username]
        cookies[:site_password] = params[:site_password]
      end
      redirect_to next_url
    else
      @error = true
      render :new
    end
  end

  protected
    def default_url_options
      { path_prefix: params[:path_prefix], locale: params[:locale] }
    end

  private
    def meta_desc
      'Page protected - Please log in'
    end

    def title
      'Page protected - Please log in'
    end
end