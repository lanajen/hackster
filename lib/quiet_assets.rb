# Usage: in develoopment.rb
#
#   config.middleware.insert_before Rails::Rack::Logger, DisableAssetsLogger
#

class DisableAssetsLogger
  def initialize(app)
    unless ENV['LOG_ASSETS']
      puts "Deactivating asset logging."
      puts "To see asset requests in log, start with LOG_ASSETS=true env variable."
    end

    @app = app
    Rails.application.assets.logger = Logger.new('/dev/null')
  end

  def call(env)
    previous_level = Rails.logger.level
    Rails.logger.level = Logger::ERROR if (env['PATH_INFO'].starts_with?("/assets/") or env['PATH_INFO'].starts_with?("/uploads/")) && ! ENV['LOG_ASSETS']
    @app.call(env)
  ensure
    Rails.logger.level = previous_level
  end
end

Rails.application.config.middleware.insert_before Rails::Rack::Logger, DisableAssetsLogger if Rails.env.development?