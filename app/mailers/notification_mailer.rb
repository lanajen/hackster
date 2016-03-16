class NotificationMailer < BaseMailer
  ADMIN_EMAIL = 'Ben<ben@hackster.io>'

  def deliver_email no_one, context, template, opts={}
    super

    set_header :to, ADMIN_EMAIL
    send_email nil, template
  end
end