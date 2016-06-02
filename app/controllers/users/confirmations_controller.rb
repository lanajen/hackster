class Users::ConfirmationsController < Devise::ConfirmationsController
  def new
    self.resource = resource_class.new permitted_params_for_new[:user]
    resource.email = current_user.email if user_signed_in?
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    if params[:confirmation_token].present?
      @original_token = params[:confirmation_token]
    elsif params[resource_name].try(:[], :confirmation_token).present?
      @original_token = params[resource_name][:confirmation_token]
    end

    self.resource = resource_class.find_by_confirmation_token Devise.token_generator.
      digest(self, :confirmation_token, @original_token)
    if resource.nil? or resource.confirmed?
      redirect_to root_path and return
    elsif resource.simplified_signup?
      return
    end

    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      track_event 'Confirmed their email address'
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in resource_name, resource, force: true
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      message = "Error confirming account for user ID #{resource.id}: #{resource.errors.messages}"
      log_line = LogLine.create(message: message, log_type: 'error', source: 'confirmations_controller')
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end
  end

  def confirm
    @original_token = params[resource_name].try(:[], :confirmation_token)
    self.resource = resource_class.find_by_confirmation_token! @original_token
    resource.assign_attributes(permitted_params_for_confirm)

    if resource.valid?
      self.resource.confirm!
      track_event 'Confirmed their email address'
      NotificationCenter.notify_via_email nil, :user, resource.id, 'registration_confirmation'
      set_flash_message :notice, :confirmed
      sign_in resource_name, resource, force: true
      redirect_to after_confirmation_path_for resource_name, resource
    else
      message = "Error confirming account for user ID #{resource.id}: #{resource.errors.messages}"
      log_line = LogLine.create(message: message, log_type: 'error', source: 'confirmations_controller')
      render :action => 'show'
    end
  end

  private
    def after_confirmation_path_for(resource_name, resource)
      resource.profile_needs_care? ? user_after_registration_path : super(resource_name, resource)
    end

    # The path used after resending confirmation instructions.
    def after_resending_confirmation_instructions_path_for(resource_name)
      is_navigational_format? and !user_signed_in? ? new_session_path(resource_name) : root_path
    end

    def permitted_params_for_confirm
      params.require(resource_name).permit(:password)
    end

    def permitted_params_for_new
      params.permit(resource_name => [:email])
    end
end