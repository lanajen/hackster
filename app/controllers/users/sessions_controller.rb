class Users::SessionsController < Devise::SessionsController
  protected
    def after_sign_in_path_for(resource)
      track_event 'Logged in'
      track_user current_user.to_tracker_profile

      user_return_to
    end
end