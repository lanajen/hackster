class BaseMailer < ActionMailer::Base
  include MailerHelpers
  include SendGrid

  def prepare_email type, context_type, context_id
    raise 'Illegal arguments' unless context_type.kind_of? String and context_id.kind_of? Integer
    puts "Preparing email of type '#{type}' for @context '#{context_type}' of id #{context_id}."
    @context = get_context_for context_type, context_id
    return unless @context

    sendgrid_category type
    if @context.include? :users
      return if @context[:users].empty?
      @context[:users] = @context[:users].uniq
      users_copy = @context[:users]
      users_copy..each_slice(1000) do |users|
        @context[:users] = users
        send_bulk_email type
      end
    elsif @context.include? :user
      send_single_email type
    else
      send_notification_email type
    end
    "deliver!"
  end

  def enqueue_email type, options
    self.message.perform_deliveries = false
    Resque.enqueue(MailerQueue, 'message_with_context', type, options[:context_type], options[:context_id])
  end

  def enqueue_generic_email message
    self.message.perform_deliveries = false
    Resque.enqueue(MailerQueue, 'generic_message', message.name, message.from_email, message.to_email, message.subject, message.body, message.message_type, message.recipients)
  end

  private
    def get_context_for context_type, context_id
      context = {}
      case context_type.to_sym
      when :invite_request
        context[:user] = context[:invite] = InviteRequest.find(context_id)
      when :invite_request_notification
        context[:invite] = InviteRequest.find(context_id)
      when :log_line
        context[:error] = LogLine.find(context_id)
      when :participant_invite
        context[:invite] = invite = ParticipantInvite.find(context_id)
        context[:user] = User.new email: invite.email
        context[:project] = invite.project
        context[:issue] = invite.issue
        context[:inviter] = invite.user
      when :project
        project = context[:project] = Project.find(context_id)
        context[:users] = project.users
      when :quote
        context[:quote] = Quote.find(context_id)
      when :user
        user = context[:user] = User.find(context_id)
      else
        raise "Unknown context: #{context_type}"
      end
      context
    rescue ActiveRecord::RecordNotFound
      false
    end
end
