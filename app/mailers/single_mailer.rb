class SingleMailer < BaseMailer

  def deliver_email recipient, context, template, opts={}
    super

    set_header :to, recipient.email
    send_email recipient, template, opts
  end
end