class AppLogger
  def create_log
    LogLine.create(message: @message, log_type: @log_type, source: @source)
  end

  def initialize message, log_type, source, exception=nil
    @message, @log_type, @source, @exception = message, log_type, source, exception
    if exception.present?
      @clean_backtrace = Rails.backtrace_cleaner.clean(@exception.backtrace)
      @message = "#{@exception.inspect} // backtrace: #{@clean_backtrace.join(' - ')} // " + @message
    end
  end

  def log_and_notify_with_stdout
    write_to_stdout
    log_and_notify
  end

  def log_and_notify
    log_line = create_log
    send_notification(log_line) if Rails.env == 'production'
  end

  def send_notification log_line
    NotificationCenter.notify_via_email nil, :log_line, log_line.id, 'error_notification'
  end

  def write_to_stdout
    Rails.logger.error ""
    Rails.logger.error "Exception: #{@exception.inspect}"
    Rails.logger.error ""
    @clean_backtrace.each { |line| Rails.logger.error "Backtrace: " + line }
    Rails.logger.error ""
  end
end