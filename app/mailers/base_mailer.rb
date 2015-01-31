class BaseMailer < ActionMailer::Base
  include MailerHelpers
  include SendGrid
  add_template_helper UrlHelper

  def deliver_email action, context, type, opts={}
    sendgrid_category type
    @context = context
    send action, type, opts
  end

  def enqueue_email type, options
    self.message.perform_deliveries = false
    MailerQueue.perform_async 'message_with_context', type, options[:context_type], options[:context_id]
  end

  def enqueue_devise_email type, options, devise_opts
    self.message.perform_deliveries = false
    MailerQueue.perform_async 'devise_message', type, options[:context_type], options[:context_id], devise_opts
  end

  def enqueue_generic_email message
    self.message.perform_deliveries = false
    MailerQueue.perform_async 'generic_message', message.name, message.from_email, message.to_email, message.subject, message.body, message.message_type, message.recipients
  end
end
