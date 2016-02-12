class ApplicationDecorator < Draper::Decorator
  delegate_all

  private
    def current_site
      context.has_key?(:current_site) ? context[:current_site] : h.current_site
    end

    def is_whitelabel?
      current_site.present?
    end

    def link_to_model content
      h.link_to content, model
    end
end