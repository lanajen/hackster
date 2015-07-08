class OrderDecorator < ApplicationDecorator
  def long_status
    case model.workflow_state.to_sym
    when :new
      'New order'
    when :processing, :pending_verification
      h.content_tag(:strong, "Your order is confirmed!") + " We'll send you an email when it ships."
    when :shipped
      message = h.content_tag(:strong, "Your order has been shipped!")
      message += " Track it with code #{model.tracking_number}." if model.tracking_number.present?
      message
    else
      'Unknown status'
    end
  end
end