class Users::RegistrationsController < Devise::RegistrationsController
  # copied authenticate_scope from devise otherwise it's called before
  # authenticate_from_token in application_controller.rb
  before_filter :authenticate_scope!, only: [:edit, :update, :destroy]
  before_filter :configure_permitted_parameters, only: [:create, :update]
  before_filter :disable_flash, only: [:new, :create]

  def new
    track_event 'Visited sign up page', { referrer: request.referrer, reason: params[:reason], model_type: params[:m] }

    super
  end

  def create
    if experiment = params[:experiment]
      finished experiment
    end

    super

    # logging errors that users can't see
    if resource.errors.messages.reject{|k,v| v.empty? or k.in? [:email, :email_confirmation, :password] }.any?
      message = "User couldn't sign up: #{resource.errors.inspect}"
      AppLogger.new(message, 'registrations', 'controller').log_and_notify
    end
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
      if @user.unconfirmed_email.present?
        set_flash_message :notice, :updated_email, email: @user.email
      else
        set_flash_message :notice, :updated
      end
      if params[:user][:password]  # password was changed
        # reset the session and sign in the user bypassing validation
        reset_session
        sign_in @user, bypass: true
        session_id = SessionManager.new(@user).new_session! expire: true  # create a new session and expire all others
        session[:_session_id] = session_id
        session[:_session_created_at] = Time.now.to_i
      end
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  def destroy
    # tracking their profile and why they're leaving
    data = current_user.to_tracker_profile.merge({ age: current_user.account_age })
    track_event 'Deleted account', data

    message = "#{current_user.name} (#{current_user.email}) closed account aged #{current_user.account_age} days, because \"#{params[:reason]}\"."
    AppLogger.new(message, 'closed_account', 'registrations_controller').log_and_notify(:info)

    super
  end

  protected
    def after_sign_up_path_for(resource)
      cookies[:hackster_user_signed_in] = '1'
      track_signup resource

      (is_whitelabel? and current_site.disable_onboarding_screens?) ? user_toolbox_path : user_after_registration_path
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
    def build_resource(hash=nil)
      super
      self.resource.platform = site_platform
      resource
    end

    # check if we need password to update user data
    # ie if password or email was changed
    # extend this as needed
    def needs_password?(user, params)
      params[:user][:password].present?
    end
end