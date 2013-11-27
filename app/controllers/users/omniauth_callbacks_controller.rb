class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate_user!

  def facebook
    oauthorize 'Facebook'
  end

  def github
    oauthorize 'Github'
  end

  def gplus
    oauthorize 'Google+'
  end

  def linkedin
    oauthorize 'LinkedIn'
  end

  def twitter
    oauthorize 'Twitter'
  end

  def setup
    session['devise.invitation_token'] = params[:invitation_token] if params[:invitation_token]

    render text: 'Setup complete.', status: 404
  end

  def failure
    set_flash_message :alert, :failure, :kind => OmniAuth::Utils.camelize(failed_strategy.name), :reason => failure_message

    logger.error env['omniauth.error'].to_s

    redirect_to after_omniauth_failure_path_for(resource_name)
  end

  private
    def oauthorize(kind)
      @user = User.find_for_oauth(kind, request.env['omniauth.auth'], current_user)
      # logger.info request.env['omniauth.auth'].to_yaml
      omniauth_data = request.env['omniauth.auth']  #.except("extra") Ruby 2.0.0 has smaller cookie?

      if @user
        case @user.match_by
        when 'uid'
          flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: kind
          sign_in_and_redirect @user, event: :authentication
        when 'email'#, 'name'
          session['devise.provider_data'] = omniauth_data
          session['devise.provider'] = kind
          session['devise.match_by'] = @user.match_by
          redirect_to edit_authorization_url(@user)
        end
      else
        session['devise.provider_data'] = omniauth_data
        session['devise.provider'] = kind
        redirect_to new_authorization_url(autosave: 1)
      end
    end

  protected
    def after_sign_up_path_for(resource)
      super(resource)
    end

    def after_sign_in_path_for(resource)
      super(resource)
    end
end