module JsonDecoratorHelpers
  private
    def decorator_context
      {
        context: {
          current_site: @opts[:current_site]
        }
      }
    end

    def h
      ActionController::Base.helpers
    end

    def url
      opts = @opts[:url_opts] || {}
      opts[:current_site] = @opts[:current_site] if @opts[:current_site]
      UrlGenerator.new opts
    end
end