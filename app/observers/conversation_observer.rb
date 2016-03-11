class ConversationObserver < ActiveRecord::Observer
  def after_create record
    if record.is_spam
      message = "Possible spammer: user_id = #{record.sender_id}."
      if record.errors[:sender_id]
        message += " Too many messages in last 24 hours."
      elsif record.errors[:subject]
        message += " Duplicate subjects in last 24 hours."
      end
      AppLogger.new(message, 'spam_filter', 'conversation').log_and_notify(:info)
    end
  end

  def after_validation record
    if record.is_spam
      spammer = record.spammer
      spammer.roles += ['spammer']
      spammer.save
    end
  end

  alias_method :after_update, :after_create
end