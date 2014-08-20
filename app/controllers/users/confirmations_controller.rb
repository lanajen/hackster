class Users::ConfirmationsController < Devise::ConfirmationsController
  def new
    self.resource = resource_class.new permitted_params_for_new
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
      sign_in resource_name, resource, bypass: user_signed_in?
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
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
      BaseMailer.enqueue_email 'registration_confirmation',
        { context_type: :user, context_id: resource.id }
      set_flash_message :notice, :confirmed
      sign_in resource_name, resource, bypass: user_signed_in?
      redirect_to after_confirmation_path_for resource_name, resource
    else
      render :action => 'show'
    end
  end

  private
    def after_confirmation_path_for(resource_name, resource)
      resource.profile_needs_care? ? user_after_registration_path : super(resource_name, resource)
    end

    def permitted_params_for_confirm
      params.require(resource_name).permit(:password)
    end

    def permitted_params_for_new
      params.permit(resource_name => [ :email ])
    end
end