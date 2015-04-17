class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate_user!

  def passthru
    track_event 'Connecting via social account', { referrer: request.referrer }

    super
  end

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

  def windowslive
    oauthorize 'Windowslive'
  end

  def setup
    puts 'setup'
    session.keys.grep(/^devise\./).each { |k| session.delete(k) }

    session['devise.invitation_token'] = params[:invitation_token] if params[:invitation_token]

    session[:redirect_host] = params[:redirect_host] if params[:redirect_host]

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

      redirect_host = session.delete(:redirect_host).presence || APP_CONFIG['default_host']

      omniauth_data = case kind
      when 'Facebook', 'Twitter', 'Windowslive'
        request.env['omniauth.auth'].except("extra")
      else
        request.env['omniauth.auth']
      end

      if @user
        case @user.match_by
        when 'uid'
          flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: kind
          sign_in_and_redirect @user, event: :authentication
        when 'email'#, 'name'
          session['devise.provider_data'] = omniauth_data
          session['devise.provider'] = kind
          session['devise.match_by'] = @user.match_by
          redirect_to edit__authorization_url(@user.id, host: redirect_host)
        end
      else
        session['devise.provider_data'] = omniauth_data
        session['devise.provider'] = kind
        redirect_to new__authorization_url(autosave: 1, host: redirect_host)
      end
    end

  protected
    def after_sign_in_path_for(resource)
      user_return_to
    end
end