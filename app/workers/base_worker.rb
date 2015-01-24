# require 'resque/errors'

class BaseWorker
  # extend HerokuResqueAutoScale if Rails.env == 'production'
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 5

  # class << self
    def perform method, *args
      with_logging method do
        send(method, *args)
      end
    # rescue Resque::TermException
    #   message = "Received Resque::TermException while working on #{method} with args #{args}"
      # Rails.logger.error message
    #   log_line = LogLine.create(message: message, log_type: 'error', source: 'worker')
    rescue ActiveRecord::RecordNotFound, Timeout::Error => e
      message = "Error while working on '#{method}' in '#{self.class.name}' with args #{args}: \"#{e.message}\""
      Rails.logger.error message
      log_line = LogLine.create(message: message, log_type: 'error', source: 'worker')
    end

    def with_logging(method, &block)
      log("starting...", method)

      time = Benchmark.ms do
        yield block
      end

      log("completed in (%.1fms)" % [time], method)
    end

    def log(message, method = nil)
      log_helper "%s#%s - #{message}" % [self.class.name, method]
    end

    def log_helper(message)
      now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      puts "#{now} #{message}"
    end
  # end
end