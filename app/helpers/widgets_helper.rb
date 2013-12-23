module WidgetsHelper
  def display_comments comments, output=[]
    comments.each do |comment|
      output << comment
      output = display_comments comment.children, output if comment.children
    end
    output
  end

  def lightbox_elements images
    images.map do |image|
      "{
          URL: '#{image.file_url(:lightbox)}',
          caption: '#{image.title}',
          type: 'image'
      }"
    end.join(',')
  end

  def lightbox_elements_for_urls urls
    urls.map do |url|
      "{
          URL: '#{url}',
          type: 'image'
      }"
    end.join(',')
  end

  def sort_comments comments
    display_comments Comment.sort_from_hierarchy(comments)
  end

  def widget_form_path project, widget
    @widget.persisted? ? project_widget_path(project, widget) : project_widgets_path(project)
  end

  def widget_span_class widget
    case widget
    when ImageWidget, DocumentWidget, StlWidget
      'col-xs-12'
    when PartsWidget
      'col-xs-10 col-xs-offset-1'
    else
      'col-xs-6 col-xs-offset-3'
    end
  end
end