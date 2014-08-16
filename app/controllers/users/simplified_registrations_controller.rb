class Users::SimplifiedRegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)
    resource.simplify_signup!

    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      sign_in resource_name, resource
      track_signup resource, true
      track_event 'Signed up using simplified process'
      finished 'respect_button'
      set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
      BaseMailer.enqueue_email 'registration_confirmation',
        { context_type: :user, context_id: resource.id }
      respond_with resource, location: user_return_to
    else
      render action: 'new'
    end
  end
end
# clean up all conditions to plug in better with devise api
# move welcome email to observer