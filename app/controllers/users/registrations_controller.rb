class Users::RegistrationsController < Devise::RegistrationsController
  protected
    def after_sign_up_path_for(resource)
      user_after_registration_path
    end
end