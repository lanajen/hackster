class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, only: [:create, :update]

  def new
    track_event 'Visited sign up page', { referrer: request.referrer }

    super
  end

  protected
    def after_sign_up_path_for(resource)
      track_alias
      track_user resource.to_tracker_profile
      track_event 'Signed up', { landing_page: cookies[:landing_page],
        initial_referrer: cookies[:initial_referrer] }

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