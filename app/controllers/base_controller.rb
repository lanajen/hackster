class BaseController < ActionController::Base
  include MixpanelMethods
  include UrlHelper

  force_ssl if: :ssl_configured?

  private
    def current_site
      nil
    end

    def current_platform
      nil
    end

    def default_url_options(options = {})
      # pass in the locale we have in the URL because it's always the right one
      { locale: params[:locale], protocol: (APP_CONFIG['use_ssl'] ? 'https' : 'http'), path_prefix: params[:path_prefix] }.merge options
    end

    def is_whitelabel?
      current_site.present?
    end

    def mark_last_seen! opts={}
      controller = opts[:controller] || controller_path
      action = opts[:action] || self.action_name
      request_url = opts[:request_url] || request.original_url
      referrer_url = opts[:referrer_url] || request.referrer.presence || request.headers['HTTP_ORIGIN']

      opts = {
        ip: request.ip,
        time: Time.now.to_i,
        event: "#{controller}##{action}",
        referrer_url: referrer_url,
        session_id: session.id,
        landing_url: cookies[:landing_page],
        initial_referrer: cookies[:initial_referrer],
        request_url: request_url,
      }
      TrackerQueue.perform_async 'mark_last_seen', current_user.try(:id), opts if tracking_activated?
    end

    def safe_page_params
      return nil unless params[:page]

      page = Integer params[:page]
      raise ActiveRecord::RecordNotFound if page < 1
      page
    rescue
      raise ActiveRecord::RecordNotFound
    end

    def set_current_site domain, subdomain, host
      if ENV['CLIENT_SUBDOMAIN'].present?
        ClientSubdomain.find_by_subdomain(ENV['CLIENT_SUBDOMAIN'])
      elsif domain == APP_CONFIG['default_domain']
        site = ClientSubdomain.find_by_subdomain(subdomain)
        site.present? and site.host == host ? site : nil
      else
        ClientSubdomain.find_by_domain(host)
      end
    end

    def ssl_configured?
      ssl_configured = APP_CONFIG['use_ssl']
      # if is_whitelabel?
      #   ssl_configured = (ssl_configured and !current_site.disable_https?)
      # end
      ssl_configured
    end

    def tracking_activated?
      Rails.env.production? and !current_user.try(:is?, :admin)
    end

    def user_signed_in?
      current_user and current_user.id
    end
end
