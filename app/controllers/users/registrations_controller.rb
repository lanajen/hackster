class Users::RegistrationsController < Devise::RegistrationsController
  # copied authenticate_scope from devise otherwise it's called before
  # authenticate_from_token in application_controller.rb
  before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  before_filter :configure_permitted_parameters, only: [:create, :update]

  def new
    track_event 'Visited sign up page', { referrer: request.referrer, reason: params[:reason], model_type: params[:m] }

    super
  end

  def create
    if experiment = params[:experiment]
      finished experiment
    end

    super
  end

  def update
    @user = current_user

    successfully_updated = if needs_password?(@user, params)
      @user.update_with_password(params[:user])
    else
      # remove the virtual current_password attribute update_without_password
      # doesn't know how to ignore it
      params[:user].delete(:current_password)
      @user.update_without_password(params[:user])
    end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  protected
    def after_sign_up_path_for(resource)
      time_since_shown_signup_popup = cookies[:last_shown_banner].present? ? (Time.now - cookies[:last_shown_banner].to_time) : 'never'
      data = {
        first_seen: cookies[:first_seen],
        initial_referrer: cookies[:initial_referrer],
        landing_page: cookies[:landing_page],
        shown_banner_count: cookies[:shown_banner_count],
        visits_count_before_signup: cookies[:visits].size,
      }

      track_alias
      track_user resource.to_tracker_profile.merge(data)
      track_event 'Signed up', data.merge({ time_since_shown_signup_popup: time_since_shown_signup_popup })
      # finished 'signup_button_global'

      cookies.delete(:first_seen)
      cookies.delete(:last_shown_banner)
      cookies.delete(:shown_banner_count)

      user_after_registration_path
    end

    def after_update_path_for(resource)
      user_path(resource)
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(:user_name, :email, :email_confirmation, :password)
      end
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(:email, :password, :password_confirmation, :current_password, :subscriptions)
      end
    end

  private
    # check if we need password to update user data
    # ie if password or email was changed
    # extend this as needed
    def needs_password?(user, params)
      user.email != params[:user][:email] ||
        params[:user][:password].present?
    end
end