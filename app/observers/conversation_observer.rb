class ConversationObserver < ActiveRecord::Observer
  def after_create record
    if record.is_spam
      message = "Possible spammer: user_id = #{record.sender_id}."
      if record.errors[:sender_id]
        message += " Too many messages in last 24 hours."
      elsif record.errors[:subject]
        message += " Duplicate subjects in last 24 hours."
      end
      log_line = LogLine.create(message: message, log_type: 'spam_filter', source: 'conversation')
      NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification' if ENV['ENABLE_ERROR_NOTIF']
    end
  end

  alias_method :after_update, :after_create
end