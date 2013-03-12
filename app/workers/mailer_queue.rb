class MailerQueue < BaseWorker
  @queue = :mailer

  def message_with_context type, context_type, context_id
    puts "#{Time.now.to_s} - Sending email #{type} with context '#{context_type}' and id #{context_id.to_s}."
    BaseMailer.prepare_email(type, context_type, context_id).deliver!
  end

  def generic_message name, from_email, to_email, subject, body, message_type
    message = Message.new(name: name, from_email: from_email, to_email: to_email, subject: subject, body: body, message_type: message_type)
    puts "#{Time.now.to_s} - Sending email #{message.message_type} without context."
    GenericMailer.send_message(message).deliver!
  end
end
