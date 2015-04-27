FastlyRails.configure do |config|
  config.api_key = ENV['FASTLY_API_KEY']  # Fastly api key, required
  config.max_age = 86400                  # time in seconds, optional, defaults to 2592000 (30 days)
  config.service_id = ENV['FASTLY_SERVICE_ID']   # The Fastly service you will be using, required
  config.purging_enabled = APP_CONFIG['purging_enabled']
end