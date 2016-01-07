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
      session.keys.grep(/^(devise)\./).each { |k| session.delete(k) }

      session['devise.invitation_token'] = params[:invitation_token] if params[:invitation_token]

      # session['omniauth.current_site'] = params[:current_site] if params[:current_site]
      # session['omniauth.redirect_to'] = params[:redirect_to] if params[:redirect_to] and [new_user_session_path, new_user_registration_path].exclude?(params[:redirect_to])
      # session['omniauth.link_accounts'] = params[:link_accounts] if params[:link_accounts]
      # session['omniauth.login_locale'] = params[:login_locale] if params[:login_locale]
    end

    logger.debug 'session omniauth keys (setup): ' + session.keys.grep(/^(devise|omniauth)\./).map{ |k| "#{k}: #{session[k]}" }.join(', ')

    render text: 'Setup complete.', status: 404
  end

  def failure
    message = find_message(:failure, kind: proper_name_for_provider(failed_strategy.name), reason: failure_message)

    logger.error "env['omniauth.error']: " + env['omniauth.error'].inspect

    redirect_to after_omniauth_failure_path_for(resource_name), alert: message
  end

  private
    def oauthorize(kind)
      logger.debug 'session omniauth keys (oauthorize): ' + session.keys.grep(/^(devise|omniauth)\./).map{ |k| "#{k}: #{session[k]}" }.join(', ')
      logger.debug 'omniauth.params (oauthorize): ' + request.env['omniauth.params'].map{ |k, v| "#{k}: #{v}" }.join(', ')

      params = request.env['omniauth.params']
      logger.debug 'params (oauthorize): ' + params.map{ |k, v| "#{k}: #{v}" }.join(', ')

      I18n.locale = params['login_locale'] || I18n.default_locale

      omniauth_data = case kind
      when 'facebook', 'github', 'twitter', 'windowslive'
        request.env['omniauth.auth'].except("extra")
      else
        request.env['omniauth.auth']
      end
      session['devise.provider_data'] = omniauth_data
      session['devise.provider'] = kind

      if params['link_accounts']
        redirect_to update__authorizations_path(link_accounts: true)
      else
        @user = UserOauthFinder.new.find_for_oauth(kind, omniauth_data)

        if @user
          case @user.match_by
          when 'uid'
            params[:redirect_to] = params['redirect_to']
            params[:current_site] = params['current_site']
            is_hackster = session[:current_site].present?
            flash[:notice] = I18n.t "devise.omniauth_callbacks.success_#{is_hackster ? 'hackster' : 'other'}"
            logger.debug 'after_sign_in_path_for(resource): ' + after_sign_in_path_for(@user)
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
    def after_sign_in_path_for(resource)
      cookies[:hackster_user_signed_in] = '1'

      host = ClientSubdomain.find_by_subdomain(params[:current_site]).try(:host)
      logger.debug 'current_site: ' + params[:current_site].to_s
      logger.debug 'host: ' + host.to_s

      UrlParam.new(user_return_to(host)).add_param('f', '1')
    end

    # def sign_in_and_redirect resource, opts={}
    #   host = ClientSubdomain.find_by_subdomain(session['omniauth.current_site']).try(:host)

    #   # 1. flash is shown on wrong domain
    #   # 2. when redirect_to is set to other than / it redirects to the wrong domain

    #   url = user_return_to(host)
    #   url = UrlParam.new(url).add_param(:user_token, resource.authentication_token)
    #   url = UrlParam.new(url).add_param(:user_email, resource.email)
    #   url = UrlParam.new(url).add_param('f', '1')
    #   redirect_to url
    # end

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