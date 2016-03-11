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
    if params[:setup].present?
      session.keys.grep(/^(devise|oauth)\./).each { |k| session.delete(k) }

      session['devise.invitation_token'] = params[:invitation_token] if params[:invitation_token]
    end

    render text: 'Setup complete.', status: 404
  end

  def failure
    message = find_message(:failure, kind: proper_name_for_provider(failed_strategy.name), reason: failure_message)

    logger.error "env['omniauth.error']: " + env['omniauth.error'].inspect

    redirect_to after_omniauth_failure_path_for(resource_name), alert: message
  end

  private
    def oauthorize(provider)
      # logger.debug 'session omniauth keys (oauthorize): ' + session.keys.grep(/^(devise|omniauth)\./).map{ |k| "#{k}: #{session[k]}" }.join(', ')
      # logger.debug 'omniauth.params (oauthorize): ' + request.env['omniauth.params'].map{ |k, v| "#{k}: #{v}" }.join(', ')
      request.env['omniauth.params'].delete('redirect_to') if request.env['omniauth.params']['redirect_to'].in?([new_user_session_path, new_user_registration_path])
      request.env['omniauth.params'].each{|k, v| params[k.to_sym] = v; session["oauth.#{k}"] = v }

      I18n.locale = params[:login_locale] || I18n.default_locale

      omniauth_data = case provider
      when 'facebook', 'github', 'twitter', 'windowslive'
        request.env['omniauth.auth'].except("extra")
      else
        request.env['omniauth.auth']
      end
      session['devise.provider_data'] = omniauth_data
      session['devise.provider'] = provider

      # prevent sign in if they're not arduino beta testers
      # remove these lines when the arduino site goes public
      if provider == 'arduino'
        site = ClientSubdomain.find_by_subdomain(ENV['ARDUINO_SUBDOMAIN'] || 'arduino')
        url = arduino_unauthorized_url(host: site.host, path_prefix: site.path_prefix)
        redirect_to url and return unless ArduinoUser.new(omniauth_data).is_beta_tester?
      end

      if params[:link_accounts]
        redirect_to update__authorizations_path(link_accounts: true)
      else
        @user = UserOauthFinder.new.find_for_oauth(provider, omniauth_data)

        if @user
          case @user.match_by
          when 'uid'
            is_hackster = params[:current_site].blank?
            flash[:notice] = I18n.t "devise.omniauth_callbacks.success_#{is_hackster ? 'hackster' : 'other'}"
            SocialProfile::Builder.new(provider, omniauth_data).update_credentials(@user)
            sign_in_and_redirect resource_name, @user, event: :authentication
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
    def sign_in_and_redirect resource_name, resource, opts={}
      sign_in(resource_name, resource)

      client = ClientSubdomain.find_by_subdomain(params[:current_site])
      host = client.try(:host)

      # 1. flash is shown on wrong domain
      # 2. potentially use the token login option only for different domains

      url = user_return_to(host)
      if parsed_uri = URI.parse(url) and parsed_uri.class == URI::HTTP
        parsed_uri.port = request.port unless request.port.in? [80, 443] or request.port.present?
        url = parsed_uri.to_s
      end
      if client and !client.uses_subdomain?
        url = UrlParam.new(url).add_param(:user_token, resource.authentication_token)
        url = UrlParam.new(url).add_param(:user_email, resource.email)
      end
      url = UrlParam.new(url).add_param('f', '1')
      redirect_to url
    end

    def after_omniauth_failure_path_for resource_name
      site = ClientSubdomain.find_by_subdomain(params[:current_site])

      if site.try(:disable_login?)
        site.base_uri(request.scheme) + root_path
      else
        url = new_user_session_path
        url = site.base_uri(request.scheme) + url if site
        url
      end
    end
end