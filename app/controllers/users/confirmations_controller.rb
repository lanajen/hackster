class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    if params[:confirmation_token].present?
      @original_token = params[:confirmation_token]
    elsif params[resource_name].try(:[], :confirmation_token).present?
      @original_token = params[resource_name][:confirmation_token]
    end

    self.resource = resource_class.find_by_confirmation_token Devise.token_generator.
      digest(self, :confirmation_token, @original_token)
    return if resource.nil? or resource.confirmed? or resource.simplified_signup?

    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      # Add confirmed_user to the user's roles
      resource.add_confirmed_role
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end
  end

  def confirm
    @original_token = params[resource_name].try(:[], :confirmation_token)
    self.resource = resource_class.find_by_confirmation_token! @original_token
    resource.assign_attributes(permitted_params)

    if resource.valid?
      self.resource.confirm!
      set_flash_message :notice, :confirmed
      sign_in resource_name, resource
      redirect_to after_confirmation_path_for resource_name, resource
    else
      render :action => 'show'
    end
  end

  private
    def after_confirmation_path_for(resource_name, resource)
      resource.profile_needs_care? ? user_after_registration_path : super(resource_name, resource)
    end

    def permitted_params
      params.require(resource_name).permit(:password)
    end
end