module JsonDecoratorHelpers
  extend ActiveSupport::Concern
  include AbstractController::Helpers

  private
    def decorator_context
      {
        context: {
          current_site: @opts[:current_site]
        }
      }
    end

    def h
      @hh ||= begin
        proxy = ActionView::Base.new
        proxy.extend _helpers
        proxy.extend ApplicationHelper
      end
    end

    def url
      opts = @opts[:url_opts] || {}
      opts[:current_site] = @opts[:current_site] if @opts[:current_site]
      UrlGenerator.new opts
    end
end