module WidgetsHelper
  def widget_form_path stage, widget
    @widget.persisted? ? stage_widget_path(stage, widget) : stage_widgets_path(stage)
  end
end