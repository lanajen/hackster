class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
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
end