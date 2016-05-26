class ReceiptJsonDecorator < BaseJsonDecorator
  def node
    notification = model.receivable

    {
      message: notification.decorate(context: { current_user: @opts[:current_user] }).message,
      time: h.time_diff_in_natural_language(notification.created_at, Time.now, 'ago'),
      read: model.read,
    }
  end
end