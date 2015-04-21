# intermediary class that allows passing notification handling to background
class NotificationCenter < BaseWorker
  def self.notify_all event, context_type, context_id, template=nil
    perform_async 'notify_all', event, context_type, context_id, template
  end

  def self.notify_via_email event, context_type, context_id, template=nil
    puts 'hi!'
    perform_async 'notify_via_email', event, context_type, context_id, template
  end

  def perform method_name, event, context_type, context_id, *method_args
    with_logging method_name do
      NotificationHandler.new(event, context_type, context_id).send(method_name, *method_args)
    end
  rescue ActiveRecord::RecordNotFound, Timeout::Error => e
    message = "Error while working on '#{method_name}' in '#{self.class.name}' with args #{method_args}: \"#{e.message}\""
    Rails.logger.error message
    log_line = LogLine.create(message: message, log_type: 'error', source: 'worker')
  end
end

# NotificationQueue.perform_async 'notify_all', event, context_type, context_id, *args