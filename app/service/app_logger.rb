class AppLogger
  def create_log
    LogLine.create(message: @message, log_type: @log_type, source: @source)
  end

  def log
    create_log
    self
  end

  def initialize message, log_type, source, exception=nil
    @message, @log_type, @source, @exception = clean_message(message), log_type, source, exception
    if exception.present? and exception.backtrace
      @clean_backtrace = Rails.backtrace_cleaner.clean(exception.backtrace)
      @message = "#{exception.inspect} // backtrace: #{@clean_backtrace.join(' - ')} // " + @message
    end

    # cache the error in redis and count how many times it happened in last 10min
    if exception and count = redis.get(exception_key)
      @count = count.to_i + 1
      ttl = redis.ttl exception_key
      ttl = 6000 if ttl == -1
      puts 'count: ' + count.to_s
      puts 'ttl: ' + ttl.to_s
      redis.setex exception_key, ttl, @count
      @message = "**#{@count} times in last 10min** " + @message
    else
      @count = 1
      # expire the key automatically in 10 min
      redis.setex exception_key, 6000, @count
    end
  end

  def log_and_notify_with_stdout
    write_to_stdout
    log_and_notify
  end

  def log_and_notify level=:error, force=false
    log_line = create_log

    # send only 1 in 100 instances of errors
    if force or (ENV['ENABLE_ERROR_NOTIF'] and (@count == 1 or (@count - 1) % 100 == 0))
      send_notification(log_line, level)
    end
  end

  def send_notification log_line, level
    NotificationCenter.notify_via_email nil, :log_line, log_line.id, "#{level}_notification"
    self
  end

  alias_method :notify, :send_notification

  def write_to_stdout
    Rails.logger.error ""
    Rails.logger.error "Exception: #{@exception.inspect}"
    Rails.logger.error ""
    @clean_backtrace.each { |line| Rails.logger.error "Backtrace: " + line } if @clean_backtrace
    Rails.logger.error ""
    self
  end

  alias_method :stdout, :write_to_stdout

  private
    def clean_message msg
      msg.gsub /"([^"]*)password"=>"([^"]+)"/, '"' + $1.to_s + 'password"=>"FILTERED"'
    end

    def exception_key
      @exception ? @exception.class.name.underscore : "#{@log_type}:#{@source}"
    end

    def redis
      @redis ||= Redis::Namespace.new('app_logger', redis: RedisConn.conn)
    end
end