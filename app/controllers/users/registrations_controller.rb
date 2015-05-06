class Users::RegistrationsController < Devise::RegistrationsController
  # copied authenticate_scope from devise otherwise it's called before
  # authenticate_from_token in application_controller.rb
  before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
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
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  protected
    def after_sign_up_path_for(resource)
      cookies[:hackster_user_signed_in] = '1'
      track_signup resource

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