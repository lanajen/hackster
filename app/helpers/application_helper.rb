module ApplicationHelper
  def class_for_alert alert, notice
    if alert
      return { class: 'alert-error' }
    elsif notice
      return { class: 'alert-success' }
    else
      return { style: 'display:none;' }
    end
  end
end
