class ApplicationController < ActionController::Base
  include MixpanelMethods
  include UrlHelper

  force_ssl if: :ssl_configured?

  helper_method :current_platform
  helper_method :current_site
  helper_method :is_whitelabel?
  helper_method :site_name

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActionController::RoutingError,
      ActionController::UnknownFormat,
      ActionController::UnknownController,
      AbstractController::ActionNotFound,
      ActiveRecord::RecordNotFound,
      with: :render_404
    rescue_from ActionView::MissingTemplate, with: :render_404_with_log
    rescue_from Exception, with: :render_500
  end

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

    def impressionist_async obj, message, opts
      if obj.kind_of? Hash
        obj_id = obj[:id]
        obj_type = obj[:type]
      else
        obj_id = obj.id
        obj_type = obj.class.to_s
      end
      ImpressionistQueue.perform_async 'count', { "action_dispatch.remote_ip" => request.remote_ip, "HTTP_REFERER" => (opts.delete(:referrer).presence || request.referer), 'HTTP_USER_AGENT' => request.user_agent, session_hash: (request.session_options[:id].presence || SecureRandom.hex(16)) }, (opts.delete(:action_name).presence || action_name), (opts.delete(:controller_name).presence || controller_name), params, obj_id, obj_type, message, opts
    rescue
    end

    def is_whitelabel?
      current_site.present?
    end

    def log_error exception
      message = "user: #{current_user.try(:user_name)} // request_url: #{request.url} // referrer: #{request.referrer} // request_params: #{request.params.to_s} // user_agent #{request.headers['HTTP_USER_AGENT']} // ip: #{request.remote_ip} // format: #{request.format} // HTTP_X_REQUESTED_WITH: #{request.headers['HTTP_X_REQUESTED_WITH']}"
      AppLogger.new(message, 'error', 'controller', exception).log_and_notify_with_stdout
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

    def render_404(exception)
      # implemented downstream
    end

    def render_404_with_log(exception)
      log_error exception
      render_404 exception
    end

    def render_500(exception)
      begin
        log_error exception
      rescue
      end
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
