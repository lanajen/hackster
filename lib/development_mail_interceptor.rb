class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "[#{message.to}] #{message.subject}"
    message.to = "benjamin.larralde@gmail.com"
  end
end