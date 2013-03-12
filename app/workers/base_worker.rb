class BaseWorker
  extend HerokuResqueAutoScale if Rails.env == 'production'

  class << self
    def perform method, *args
      with_logging method do
        self.new.send(method, *args)
      end
    end

    def with_logging(method, &block)
      log("starting...", method)

      time = Benchmark.ms do
        yield block
      end

      log("completed in (%.1fms)" % [time], method)
    end

    def log(message, method = nil)
      log_helper "%s#%s - #{message}" % [self.name, method]
    end

    def log_helper(message)
      now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      puts "#{now} #{message}"
    end
  end
end