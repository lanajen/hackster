class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, only: [:create, :update]
  # def new
  #   options = { invitation_code: params[:invitation_code] }
  #   build_resource(options)
  #   respond_with self.resource
  # end

  protected
    def after_sign_up_path_for(resource)
      track_user @user.to_tracker_profile
      track_event 'Signed up'

      user_after_registration_path
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(:user_name, :email, :email_confirmation, :password)
      end
      # devise_parameter_sanitizer.for(:account_update) do |u|
      #   u.permit(:user_name)
      # end
    end
end