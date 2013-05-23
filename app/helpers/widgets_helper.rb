module WidgetsHelper
  def widget_form_path project, widget
    @widget.persisted? ? project_widget_path(project, widget) : project_widgets_path(project)
  end
end