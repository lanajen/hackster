class Users::AuthorizationsController < Users::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [:new, :create]
  prepend_before_filter :authenticate_scope!, :only => [:destroy]
  prepend_before_filter :allow_params_authentication!, :only => :update
  before_filter :ensure_provider_data
  before_filter :configure_permitted_parameters

  def new
    options = { invitation_token: session['devise.invitation_token'] }
    build_resource(options)
    resource.email = resource.email_confirmation = '' if params[:new_email]
    if params[:autosave] and resource.save
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
      resource.link_to_provider session['devise.provider'], session['devise.provider_data'].uid, session['devise.provider_data']
      set_flash_message(:notice, :linked_and_signed_in) if is_navigational_format?
      redirect_to edit_registration_path(resource)
    else
      resource = warden.authenticate!({ :scope => resource_name, :recall => "#{controller_path}#edit" })
      resource.link_to_provider session['devise.provider'], session['devise.provider_data'].uid, session['devise.provider_data']
      set_flash_message(:notice, :linked_and_signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
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
      track_event 'Connected with social account', { provider: resource.authorizations.first.try(:provider) }
      super(resource)
    end

    # def after_sign_in_path_for(resource)
    #   super(resource)
    # end

    def build_resource(hash = nil)
      hash ||= resource_params || {}
      if hash[:invitation_token].present?
        self.resource = resource_class.where(invitation_token: hash[:invitation_token]).first
        if self.resource
          self.resource.extract_from_social_profile params, session
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
end