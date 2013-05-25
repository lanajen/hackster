module WidgetsHelper
  def widget_form_path project, widget
    @widget.persisted? ? project_widget_path(project, widget) : project_widgets_path(project)
  end

  def widget_span_class widget
    case widget
    when nil
      'span12'
    else
      'span6 offset3'
    end
  end
end