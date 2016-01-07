class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include ApplicationHelper
  skip_before_filter :authenticate_user!
  skip_before_filter :set_locale
  protect_from_forgery except: :saml

  def passthru
    track_event 'Connecting via social account', { referrer: request.referrer }

    super
  end

  def arduino
    oauthorize 'arduino'
  end

  def facebook
    oauthorize 'facebook'
  end

  def github
    oauthorize 'github'
  end

  def gplus
    oauthorize 'gplus'
  end

  def linkedin
    oauthorize 'linkedin'
  end

  def saml
    oauthorize 'saml'
  end

  def twitter
    oauthorize 'twitter'
  end

  def windowslive
    oauthorize 'windowslive'
  end

  def setup
    logger.debug 'crsf: ' + form_authenticity_token.to_s
    if params[:setup].present?
      session.keys.grep(/^(devise|omniauth)\./).each { |k| session.delete(k) }

      session['devise.invitation_token'] = params[:invitation_token] if params[:invitation_token]

      session['omniauth.current_site'] = params[:current_site] if params[:current_site]
      session['omniauth.redirect_to'] = params[:redirect_to] if params[:redirect_to] and [new_user_session_path, new_user_registration_path].exclude?(params[:redirect_to])
      session['omniauth.link_accounts'] = params[:link_accounts] if params[:link_accounts]
      session['omniauth.login_locale'] = params[:login_locale] if params[:login_locale]
    end

    logger.debug 'session omniauth keys: ' + session.keys.grep(/^(devise|omniauth)\./).map{ |k, v| "#{k}: #{v}" }.join(', ')

    render text: 'Setup complete.', status: 404
  end

  def failure
    message = find_message(:failure, kind: proper_name_for_provider(failed_strategy.name), reason: failure_message)

    logger.error "env['omniauth.error']: " + env['omniauth.error'].inspect

    redirect_to after_omniauth_failure_path_for(resource_name), alert: message
  end

  private
    def oauthorize(kind)
      # logger.info "request.env['omniauth.auth']: " + request.env['omniauth.auth'].to_yaml

      I18n.locale = session.delete('omniauth.login_locale') || I18n.default_locale

      omniauth_data = case kind
      when 'facebook', 'github', 'twitter', 'windowslive'
        request.env['omniauth.auth'].except("extra")
      else
        request.env['omniauth.auth']
      end
      session['devise.provider_data'] = omniauth_data
      session['devise.provider'] = kind

      if session.delete('omniauth.link_accounts')
        redirect_to update__authorizations_path(link_accounts: true)
      else
        @user = UserOauthFinder.new.find_for_oauth(kind, omniauth_data)

        if @user
          case @user.match_by
          when 'uid'
            params[:redirect_to] = session.delete('omniauth.redirect_to')
            is_hackster = session[:current_site].present?
            flash[:notice] = I18n.t "devise.omniauth_callbacks.success_#{is_hackster ? 'hackster' : 'other'}"
            sign_in_and_redirect @user, event: :authentication
          when 'email'#, 'name'
            session['devise.match_by'] = @user.match_by
            redirect_to edit__authorization_path(@user.id)
          end
        else
          redirect_to new__authorization_path(autosave: 1)
        end
      end
    end

  protected
    def sign_in_and_redirect resource, opts={}
      host = ClientSubdomain.find_by_subdomain(session['omniauth.current_site']).try(:host)

      url = user_return_to(host)
      url = UrlParam.new(url).add_param(:user_token, resource.authentication_token)
      url = UrlParam.new(url).add_param(:user_email, resource.email)
      url = UrlParam.new(url).add_param('f', '1')
      redirect_to url
    end

    def after_omniauth_failure_path_for resource_name
      site = ClientSubdomain.find_by_subdomain(session['omniauth.current_site'])

      if site.try(:disable_login?)
        site.base_uri(request.scheme) + root_path
      else
        url = new_user_session_path
        url = site.base_uri(request.scheme) + url if site
        url
      end
    end
end