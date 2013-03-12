class GenericMailer < BaseMailer
  def send_message message
    @message = message
    type = @message.message_type

    headers = {
      :subject => render_to_string("mailers/subjects/#{type}"),
      :from =>  @message.from_email.present? ? "#{@message.name}<#{@message.from_email}>" : DEFAULT_EMAIL,
      :to => @message.to_email || DEFAULT_EMAIL,
    }

    mail(headers) do |format|
      format.html { render :text => render_to_string("mailers/bodies/#{type}") }
    end
  end
end