class UrlGenerator
  include Rails.application.routes.url_helpers
  include UrlHelper

  def initialize opts={}
    @host = opts[:host]
  end

  private
    def default_url_options(options = {})
      { locale: nil, host: @host }.merge options
    end
end