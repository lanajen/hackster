module ApplicationHelper
  def active_li_link_to content, link, options={}
    link = url_for link
    klass = 'active' if link == request.path or (options[:truncate] and link.in? request.path)
    content_tag(:li, link_to(content, link), class: klass)
  end

  def class_for_alert alert, notice
    if alert
      return { class: 'alert-error' }
    elsif notice
      return { class: 'alert-success' }
    else
      return { style: 'display:none;' }
    end
  end

  # tire results don't implement to_param so need to make it work here
  def result_to_model result
    result._type.classify.constantize.send :find, result.id
  end
end
