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
    oauthorize 'Microsoft'
  end

  def setup
    session.keys.grep(/^devise\./).each { |k| session.delete(k) }

    session['devise.invitation_token'] = params[:invitation_token] if params[:invitation_token]

    session[:redirect_host] = params[:redirect_host] if params[:redirect_host]
    session[:redirect_to] = params[:redirect_to] if params[:redirect_to] and [new_user_session_path, new_user_registration_path].exclude?(params[:redirect_to])
    session[:link_accounts] = params[:link_accounts] if params[:link_accounts]

    render text: 'Setup complete.', status: 404
  end

  def failure
    set_flash_message :alert, :failure, :kind => OmniAuth::Utils.camelize(failed_strategy.name), :reason => failure_message

    logger.error env['omniauth.error'].to_s

    redirect_to after_omniauth_failure_path_for(resource_name)
  end

  private
    def oauthorize(kind)
      # logger.info request.env['omniauth.auth'].to_yaml

      @redirect_host = session.delete(:redirect_host).presence || APP_CONFIG['default_host']
      is_hackster = @redirect_host == APP_CONFIG['default_host']
      params[:redirect_to] = session.delete(:redirect_to)

      omniauth_data = case kind
      when 'Facebook', 'Github', 'Twitter', 'Microsoft'
        request.env['omniauth.auth'].except("extra")
      else
        request.env['omniauth.auth']
      end

      if session.delete(:link_accounts)
        session['devise.provider_data'] = omniauth_data
        session['devise.provider'] = kind
        redirect_to update__authorizations_url(host: @redirect_host, link_accounts: true)
      else
        @user = User.find_for_oauth(kind, request.env['omniauth.auth'], current_user)

        if @user
          case @user.match_by
          when 'uid'
            flash[:notice] = I18n.t "devise.omniauth_callbacks.success_#{is_hackster ? 'hackster' : 'other'}"
            sign_in_and_redirect @user, event: :authentication
          when 'email'#, 'name'
            session['devise.provider_data'] = omniauth_data
            session['devise.provider'] = kind
            session['devise.match_by'] = @user.match_by
            redirect_to edit__authorization_url(@user.id, host: @redirect_host)
          end
        else
          session['devise.provider_data'] = omniauth_data
          session['devise.provider'] = kind
          redirect_to new__authorization_url(autosave: 1, host: @redirect_host)
        end
      end
    end

  protected
    def after_sign_in_path_for(resource)
      cookies[:hackster_user_signed_in] = '1'

      user_return_to(@redirect_host) + '?f=1'
    end
end