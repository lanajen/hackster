class Users::SessionsController < Devise::SessionsController
  before_filter :disable_flash
  before_filter :set_action, only: [:new, :create]

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

    # is there a way to not have to duplicate the following code to change the flash message?
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :"signed_in_#{site_platform == 'hackster' ? 'hackster' : 'other'}") if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  def destroy
    super
    if is_whitelabel? and current_site.has_javascript_on_logout?
      flash[:js] = current_site.javascript_on_logout
    end
  end

  protected
    def after_sign_in_path_for(resource)
      track_alias
      track_event 'Logged in'
      track_user current_user.to_tracker_profile
      cookies[:hackster_user_signed_in] = '1'

      unless current_user.toolbox_shown
        user_toolbox_path(ref: 'sign_in')
      else
        user_return_to
      end
    end

    def after_sign_out_path_for(resource)
      if resource == :user
        track_event 'Logged out'
        reset_current_mixpanel_user
      end

      if is_whitelabel? and current_site.has_custom_logout_url?
        current_site.logout_redirect_url
      else
        out = super resource
        UrlParam.new(out).add_param(:logged_out, '1')
      end
    end

    def set_action
      @action = params[:a] || 'login'
    end
end