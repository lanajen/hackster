class UrlGenerator
  include Rails.application.routes.url_helpers
  include UrlHelper

  def initialize opts={}
    @host = opts[:host] || APP_CONFIG['full_host']
  end

  private
    def default_url_options(options = {})
      { locale: nil, host: @host }.merge options
    end

    def is_whitelabel?
      false
    end
end