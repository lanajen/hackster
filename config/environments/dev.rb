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
  config.assets.js_compressor = :uglifier

  # Generate digests for assets URLs
  config.assets.digest = true

  # store assets in a 'folder' instead of bucket root
  # config.assets.prefix = "/assets/dev"

  # config.action_controller.asset_host = "//s3.amazonaws.com/#{ENV['FOG_DIRECTORY']}"
  # config.action_controller.asset_host = ENV['ASSET_HOST']
  config.static_cache_control = 'public, s-maxage=31536000, maxage=31536000'

  config.eager_load = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

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

  config.action_mailer.default_url_options = { :host => 'dev.hackster.io' }

  # config.assets.initialize_on_precompile = false

  config.react.variant = :production

  # config.middleware.use(Oink::Middleware, logger: Hodel3000CompliantLogger.new(STDOUT))

  require File.expand_path('../../../lib/queue_time_logger', __FILE__)
  config.middleware.use QueueTimeLogger

  require File.expand_path('../../../lib/log_request_id', __FILE__)
  config.middleware.use Rack::LogRequestID

  if ENV["MEMCACHIER_SERVERS"]
    config.cache_store = :dalli_store, ENV["MEMCACHIER_SERVERS"].split(','), { username: ENV["MEMCACHIER_USERNAME"], password: ENV["MEMCACHIER_PASSWORD"], compress: true }
  end

  config.middleware.insert_after(::Rack::Runtime, "::Rack::Auth::Basic", "Restricted access") do |u, p|
    [u, p] == [ENV['SITE_USERNAME'], ENV['SITE_PASSWORD']]
  end
end
