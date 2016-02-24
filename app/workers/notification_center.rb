# intermediary class that allows passing notification handling to background
class NotificationCenter < BaseWorker
  def self.notify_all event, context_type, context_id, template=nil
    perform_in 1.second, 'notify_all', event, context_type, context_id, template
  end

  def self.notify_via_email event, context_type, context_id, template=nil, opts={}
    perform_in 1.second, 'notify_via_email', event, context_type, context_id, template, opts
  end

  def perform method_name, event, context_type, context_id, *method_args
    with_logging method_name do
      NotificationHandler.new(event, context_type, context_id).send(method_name, *method_args)
    end
  rescue ActiveRecord::RecordNotFound, Timeout::Error => e
    message = "Error while working on '#{method_name}' in '#{self.class.name}' with args `#{event}`, `#{context_type}`, `#{context_id}`, #{method_args}: \"#{e.message}\""
    AppLogger.new(message, 'error', 'worker', e).create_log
  rescue => e
    message = "Error while working on '#{method_name}' in '#{self.class.name}' with args `#{event}`, `#{context_type}`, `#{context_id}`, #{method_args}: \"#{e.message}\""
    AppLogger.new(message, 'error', 'worker', e).log_and_notify_with_stdout
    raise e
  end
end

# NotificationQueue.perform_async 'notify_all', event, context_type, context_id, *args