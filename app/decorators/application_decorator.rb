class ApplicationDecorator < Draper::Decorator
  private
    def link_to_model content
      h.link_to content, model
    end
end