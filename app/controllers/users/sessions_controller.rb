class Users::SessionsController < Devise::SessionsController
  protected
    def after_sign_in_path_for(resource)
      track_event 'Logged in'

      user_return_to
    end
end