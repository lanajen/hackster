class Users::RegistrationsController < Devise::RegistrationsController
  def new
    options = { invitation_code: params[:invitation_code] }
    build_resource(options)
    respond_with self.resource
  end

  protected
    def after_sign_up_path_for(resource)
      track_user @user.to_tracker_profile
      track_event 'Signed up'

      user_after_registration_path
    end
end