class GenericMailer < BaseMailer
  def send_message message
    @message = message
    @email = Email.find_by_type(@message.message_type)
    @context = {
      message: @message
    }

    headers = {
      subject: substitute_in(@email.subject),
      from: @message.from_email.present? ? "#{@message.name}<#{@message.from_email}>" : DEFAULT_EMAIL,
      reply_to: @message.from_email.present? ? "#{@message.name}<#{@message.from_email}>" : DEFAULT_EMAIL,
      tags: [@message.message_type],
    }

    if @message.recipients.present?
      recipients = @message.recipients.split(/(\s+|;)/)
      recipients = recipients.select { |e| e.match(/^\b[a-z0-9._%-]+@[a-z0-9.-]+\.[a-z]{2,4}\b$/) }
      headers[:to] = recipients
    else
      headers[:to] = @message.to_email || DEFAULT_EMAIL
    end

    premailer = Premailer.new(substitute_in(@email.body), with_html_string: true,
      warn_level: Premailer::Warnings::SAFE)

    mail(headers) do |format|
      format.text { render text: premailer.to_plain_text }
      format.html { render text: premailer.to_inline_css }
    end
  end
end