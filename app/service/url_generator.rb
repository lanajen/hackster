class UrlGenerator
  include Rails.application.routes.url_helpers
  include UrlHelper

  attr_accessor :locale, :path_prefix

  def initialize opts={}
    @host = opts[:host] || APP_CONFIG['full_host']
    @locale = opts[:locale]
    @path_prefix = opts[:path_prefix]
    @current_site = opts[:current_site]
  end

  private
    def default_url_options(options = {})
      { locale: locale, host: @host, protocol: (APP_CONFIG['use_ssl'] ? 'https' : 'http'), path_prefix: path_prefix }.merge options
    end

    def is_whitelabel?
      @current_site.present?
    end
end