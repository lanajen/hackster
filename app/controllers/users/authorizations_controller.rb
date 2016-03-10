class Users::AuthorizationsController < Users::RegistrationsController
  prepend_before_filter :require_no_authentication, only: [:new, :create]
  prepend_before_filter :authenticate_scope!, only: [:destroy]
  prepend_before_filter :allow_params_authentication!, only: :update
  before_filter :ensure_provider_data
  before_filter :configure_permitted_parameters
  helper_method :social_profile_attributes
  layout 'authorizations'

  def new
    options = { invitation_token: session['devise.invitation_token'] }
    build_resource(options)
    resource.email = resource.email_confirmation = '' if params[:new_email]
    if params[:autosave] and resource.save
      Rails.logger.debug 'resource: ' + resource.inspect
      resource.accept_invitation!
      set_flash_message :notice, :signed_up if is_flashing_format?
      sign_up(resource_name, resource)
      redirect_to after_sign_up_path_for(resource)
    else
      logger.error resource.errors.inspect
      resource.authorizations.each{|a| logger.error a.errors.inspect }
      message = "Error authorizing account for #{resource.inspect}: #{resource.errors.messages} // #{resource.authorizations.map{|a| a.errors.inspect }.join(' // ')}"
      log_line = LogLine.create(message: message, log_type: 'social_signup_error', source: 'authorizations_controller#new')
      resource.errors.clear
      respond_with resource
    end
  end

  def edit
    self.resource = resource_class.find(params[:id])
    resource.invitation_token = session['devise.invitation_token'] if session['devise.invitation_token']
    @match_by_type = session['devise.match_by']
    @match_by_value = case @match_by_type
    when 'email'
      resource.email
    when 'name'
      resource.name
    end
  end

  def update
    if params[:link_accounts]
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      resource.link_to_provider session['devise.provider'], session['devise.provider_data']
      resource.save
      set_flash_message(:notice, :linked_and_signed_in) if is_navigational_format?
      redirect_to edit_registration_path(resource)
    else
      unless params[:user].try(:[], :authentication_token) and self.resource = find_user_and_validate_auth_token(params[:user][:email], params[:user][:authentication_token])
      end
      resource.link_to_provider session['devise.provider'], session['devise.provider_data']
      resource.save
      set_flash_message(:notice, :linked_and_signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      redirect_to after_sign_in_path_for(resource)
    end
  end

  private
    def ensure_provider_data
      raise ActionController::RoutingError, 'Not found' unless session.include? 'devise.provider' and session.include? 'devise.provider_data'
      @provider = session['devise.provider']
    end

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(:full_name, :email, :email_confirmation, :mini_resume, :city, :country, :user_name, :invitation_code, :invitation_token)
      end
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(:full_name, :email, :email_confirmation, :mini_resume, :city, :country, :user_name, :invitation_code, :invitation_token)
      end
    end

    def after_sign_up_path_for(resource)
      cookies[:hackster_user_signed_in] = '1'
      track_event 'Connected with social account', { provider: resource.authorizations.first.try(:provider) }
      build_path(super(resource), resource)
    end

    def after_sign_in_path_for(resource)
      cookies[:hackster_user_signed_in] = '1'

      host = ClientSubdomain.find_by_subdomain(session['oauth.current_site']).try(:host) || APP_CONFIG['default_host']

      params[:redirect_to] = session.delete('oauth.redirect_to')
      # logger.debug 'user_return_to: ' + user_return_to(host).to_s
      build_path(user_return_to(host), resource)
    end

    def build_path orig_path, resource
      current_site_name = session.delete('oauth.current_site')
      return orig_path unless current_site_name

      current_site = ClientSubdomain.find_by_subdomain(current_site_name)
      return orig_path unless current_site

      url = if URI.parse(orig_path).class == URI::HTTP
        orig_path
      else
        url = "#{request.scheme}://#{current_site.full_domain}"
        if current_site.has_path_prefix? and !orig_path.starts_with? "/#{current_site.path_prefix}"
          url << "/#{current_site.path_prefix}"
        end
        # logger.debug 'base_uri: ' + url.to_s
        url << orig_path
      end
      url = UrlParam.new(url).add_param('f', '1')
      url = UrlParam.new(url).add_param(:user_token, resource.authentication_token)
      url = UrlParam.new(url).add_param(:user_email, resource.email)
      url
    end

    def build_resource(hash = nil)
      hash ||= resource_params || {}
      if hash[:invitation_token].present?
        self.resource = resource_class.where(invitation_token: hash[:invitation_token]).first
        if self.resource
          self.resource = SocialProfile::Builder.new(session['devise.provider'], session['devise.provider_data']).initialize_user_from_social_profile(resource)
          self.resource.attributes = hash
          self.resource.accept_invitation
          self.resource.invitation_token = hash[:invitation_token]
        end
      end
      if resource
        resource.platform = site_platform
      else
        self.resource = super
      end
    end

    def current_site
      return unless session['oauth.current_site'].present?

      return @current_site if @current_site

      @current_site = ClientSubdomain.find_by_subdomain(session['oauth.current_site'])
    end

    def current_platform
      return unless current_site

      return @current_platform if @current_platform

      @current_platform = current_site.try(:platform)
    end

    def social_profile_attributes
      SocialProfile::Builder.new(session['devise.provider'], session['devise.provider_data']).social_profile_attributes
    end
end