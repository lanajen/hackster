class UrlGenerator
  include Rails.application.routes.url_helpers
  include UrlHelper

  def initialize opts={}
    @host = opts[:host] || APP_CONFIG['full_host']
  end

  private
    def default_url_options(options = {})
      { locale: nil, host: @host, protocol: (APP_CONFIG['use_ssl'] ? 'https' : 'http'), path_prefix: nil }.merge options
    end

    def is_whitelabel?
      false
    end
end