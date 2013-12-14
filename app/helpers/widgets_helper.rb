module WidgetsHelper
  def lightbox_elements images
    images.map do |image|
      "{
          URL: '#{image.file_url(:lightbox)}',
          caption: '#{image.title}',
          type: 'image'
      }"
    end.join(',')
  end

  def widget_form_path project, widget
    @widget.persisted? ? project_widget_path(project, widget) : project_widgets_path(project)
  end

  def widget_span_class widget
    case widget
    when ImageWidget
      'col-xs-12'
    when PartsWidget
      'col-xs-10 col-xs-offset-1'
    else
      'col-xs-6 col-xs-offset-3'
    end
  end
end