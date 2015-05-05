module WidgetsHelper
  def display_comments comments, output=[]
    comments.each do |comment|
      output << comment
      output = display_comments comment.children, output if comment.children
    end
    output
  end

  def icon_for_widget widget
    case widget
    when TextWidget
      'fa-align-left'
    when ImageWidget
      'fa-picture-o'
    when CodeWidget, GithubWidget, BitbucketWidget
      'fa-code'
    when DocumentWidget
      'fa-files-o'
    when BuyWidget, PaypalWidget
      'fa-shopping-cart'
    when VideoWidget
      'fa-film'
    when UpverterWidget, CircuitsioWidget, OshparkWidget, StlWidget
      'fa-gears'
    when CreditsWidget
      'fa-group'
    when PartsWidget
      'fa-puzzle-piece'
    else
      'fa-list-alt'
    end
  end

  def lightbox_elements images
    images.map do |image|
      "{
          URL: '#{image.imgix_url(:lightbox)}',
          caption: '#{escape_javascript image.title}',
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

  def show_expand_for? widget
    case widget
    when TextWidget, CodeWidget, PartsWidget, ImageWidget, StepByStepWidget
      true
    else
      false
    end
  end

  def sort_comments comments
    display_comments Comment.sort_from_hierarchy(comments)
  end

  def widget_form_path project, widget
    @widget.persisted? ? project_widget_path(project, widget) : project_widgets_path(project)
  end

  def widget_span_class widget
    case widget
    when ImageWidget, DocumentWidget, StlWidget, TextWidget, StepByStepWidget
      'col-xs-12'
    when PartsWidget
      'col-md-10 col-md-offset-1'
    else
      'col-md-6 col-md-offset-3'
    end
  end
end