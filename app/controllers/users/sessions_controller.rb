class Users::SessionsController < Devise::SessionsController
  before_filter :disable_flash
  before_filter :set_action, only: [:new, :create]
  protect_from_forgery except: [:create]

  def new
    track_event 'Visited log in page', { referrer: request.referrer }

    super
  end

  def create
    if params[:user] and email = params[:user][:email] and user = User.find_by_email(email)
      if user.simplified_signup?
        flash[:alert] = "You haven't created a password yet! To do so, click the link in the email we've sent you. No email? <a href='/users/confirmation/new?user[email]=#{email}' class='alert-link'>Resend confirmation email</a>.".html_safe
        redirect_to new_user_session_path and return
      end
    end

    super
  end

  protected
    def after_sign_in_path_for(resource)
      track_alias
      track_event 'Logged in'
      track_user current_user.to_tracker_profile
      cookies[:hackster_user_signed_in] = '1'

      user_return_to
    end

    def after_sign_out_path_for(resource)
      if resource == :user
        track_event 'Logged out'
        reset_current_mixpanel_user
      end
      cookies.delete(:hackster_user_signed_in)

      super resource
    end

    def set_action
      @action = params[:a] || 'login'
    end
end