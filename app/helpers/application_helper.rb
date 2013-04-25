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

  def value_for_input param, val
    param.nil? or param == val ? true : false
  end
end
