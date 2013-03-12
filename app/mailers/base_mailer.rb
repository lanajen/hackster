class BaseMailer < ActionMailer::Base
  include SendGrid
  include MailerHelpers

  DEFAULT_EMAIL = 'Ben from Halckemy<ben@halckemy.com>'
  default :from => DEFAULT_EMAIL
  default :to => DEFAULT_EMAIL

  def prepare_email type, context_type, context_id
    #TODO: limit sending to 1000 recipients and loop
    puts "Preparing email of type '#{type}' for context '#{context_type}' of id #{context_id}."
    context = get_context_for context_type, context_id
    sendgrid_category type
    if context.include? :users
      sendgrid_recipients context[:users].map { |user| user.email }
      send_bulk_email type, context
    elsif context.include? :user
      send_single_email type, context
    elsif context.include? :invite_request
      send_notification type, context
    else
      raise 'Unknown recipients in base_mailer'
    end
  end

  def enqueue_email type, options
    self.message.perform_deliveries = false
    Resque.enqueue(MailerQueue, 'message_with_context', type, options[:context_type], options[:context_id])
  end

  def enqueue_generic_email message
    self.message.perform_deliveries = false
    Resque.enqueue(MailerQueue, 'generic_message', message.name, message.from_email, message.to_email, message.subject, message.body, message.message_type)
  end

  private
    def get_context_for context_type, context_id
      context = {}
      case context_type.to_sym
      when :user
        context[:user] = User.find(context_id)
      when :invite_request
        context[:invite_request] = InviteRequest.find(context_id)
      when :log_line
        context[:log_line] = LogLine.find(context_id)
        context[:user] = User.find_by_email('benjamin.larralde@gmail.com')
      end
      context
    end
end
