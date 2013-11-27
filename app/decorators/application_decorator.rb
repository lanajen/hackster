class ApplicationDecorator < Draper::Decorator
  delegate_all

  private
    def link_to_model content
      h.link_to content, model
    end
end