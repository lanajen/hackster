class EnqueuedMailInterceptor
  def self.delivering_email(message)
    message.perform_deliveries = false if message.from.blank? and message.reply_to.blank?
  end
end