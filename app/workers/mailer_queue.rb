class MailerQueue < BaseWorker
  def self.enqueue_generic_email message
    perform_async 'generic_message', message.name, message.from_email, message.to_email, message.subject, message.body, message.message_type, message.recipients
  end

  def generic_message name, from_email, to_email, subject, body, message_type, recipients
    message = Message.new(name: name, from_email: from_email, to_email: to_email, subject: subject, body: body, message_type: message_type, recipients: recipients)
    puts "#{Time.now.to_s} - Sending email #{message.message_type} without context."
    GenericMailer.send_message(message).deliver!
  end

  def send_invites emails, user_id=nil, message=nil
    user = User.find_by_id user_id
    f = FriendInvite.new emails: emails, message: message
    f.extract_emails
    f.filter_blank_and_init!
    f.invite_all! user
  end
end

#TODO: catch Net::SMTPAuthenticationError and retry later