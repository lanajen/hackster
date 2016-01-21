class BaseWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 5

  def perform method, *args
    with_logging method, args do
      send(method, *args)
    end
  rescue ActiveRecord::RecordNotFound, Timeout::Error => e
    message = "Error while working on '#{method}' in '#{self.class.name}' with args #{args}: \"#{e.message}\""
    Rails.logger.error message
    log_line = LogLine.create(message: message, log_type: 'error', source: 'worker')
  end

  def with_logging(method, args=[], &block)
    log("starting with arguments: " + args.inspect, method)

    time = Benchmark.ms do
      yield block
    end

    log("completed in (%.1fms)" % [time], method)
  end

  def log(message, method = nil)
    message = message.gsub(/%/, '')  # cleaning up % so the line below doesn't complain of malformed string
    log_helper "%s#%s - #{message}" % [self.class.name, method]
  end

  def log_helper(message)
    Rails.logger.debug message
  end
end