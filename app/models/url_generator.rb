class UrlGenerator
  include Rails.application.routes.url_helpers
  include UrlHelper

  private
    def default_url_options(options = {})
      { locale: nil }.merge options
    end
end