class Users::RegistrationsController < Devise::RegistrationsController
  def new
    redirect_to root_url(subdomain: 'www') and return unless params[:invite_code]
    super
  end

  protected
    def after_sign_up_path_for(resource)
      session[:user_return_to] || root_url
    end
end