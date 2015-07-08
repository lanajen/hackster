class ReputationEventDecorator < ApplicationDecorator
  def to_s
    out = ''
    out << h.content_tag(:strong, h.pluralize(model.points, 'point'))
    out << ' for '
    out << h.content_tag(:strong, model.event_name)
    out << ' with '
    out << h.content_tag(:strong, "#{model.event_model_type.humanize} ID #{model.event_model_id}")
    out << ' on '
    out << h.content_tag(:strong, h.l(model.event_date))
    out.html_safe
  end
end