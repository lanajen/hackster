Rack::Timeout.timeout = ENV['RACK_TIMEOUT'].try(:to_i) || 26  # seconds. High but just to avoid crazy request queueing

Rack::Timeout::Logger.disable