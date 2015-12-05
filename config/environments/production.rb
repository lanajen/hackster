HackerIo::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned off
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false

  # Compress JavaScripts and CSS
  config.assets.css_compressor = :sass
  config.assets.js_compressor = :uglifier

  # Generate digests for assets URLs
  config.assets.digest = true

  config.static_cache_control = "public, maxage=#{1.year.to_i}"

  config.eager_load = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  config.log_level = ENV['LOG_LEVEL'] || :info

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # config.assets.initialize_on_precompile = false

  config.react.variant = :production

  require File.expand_path('../../../lib/queue_time_logger', __FILE__)
  config.middleware.use QueueTimeLogger

  require File.expand_path('../../../lib/log_request_id', __FILE__)
  config.middleware.use Rack::LogRequestID

  if ENV["MEMCACHIER_SERVERS"]
    config.cache_store = :dalli_store, ENV["MEMCACHIER_SERVERS"].split(','), { username: ENV["MEMCACHIER_USERNAME"], password: ENV["MEMCACHIER_PASSWORD"], compress: true }
  end
end