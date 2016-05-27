class Users::SimplifiedRegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  def create
    build_resource(sign_up_params)
    resource.simplify_signup!

    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      resource.send_confirmation_instructions if resource.invitation_token.present?  # not great to have this here but it's the only place I can find where I can assert that it's a simplified registration using an account that had been invited
      sign_in resource_name, resource
      track_signup resource, true
      track_event 'Signed up using simplified process', { source: params[:source], platform: site_platform }
      set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
      redirect_to user_return_to
    else
      render action: 'new'
    end
  end

  private
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :full_name) }
    end

    def build_resource(hash=nil)
      super
      self.resource.platform = site_platform
    end
end
# clean up all conditions to plug in better with devise api