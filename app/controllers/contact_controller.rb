class ContactController < ApplicationController
  def new
    @message = Message.new
  end
  
  def create
    @message = Message.new(params[:message])
    @message.message_type = 'contact'

    if @message.valid?
      BaseMailer.enqueue_generic_email(@message)
      redirect_to contact_path, notice: "Thanks for your message, we'll get back in touch very soon!"
    else
      redirect_to contact_path
    end
  end
end
