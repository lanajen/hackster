Rack::Timeout.timeout = 29  # seconds. High but just to avoid crazy request queueing

Rack::Timeout::Logger.disable