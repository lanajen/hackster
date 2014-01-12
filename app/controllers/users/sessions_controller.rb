class Users::SessionsController < Devise::SessionsController
  protected
    def after_sign_in_path_for(resource)
      track_alias
      track_event 'Logged in'
      track_user current_user.to_tracker_profile

      user_return_to
    end

    def after_sign_out_path_for(resource)
      if resource == :user
        track_event 'Logged out'
        reset_current_mixpanel_user
      end

      super resource
    end
end