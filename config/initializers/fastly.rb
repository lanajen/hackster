FastlyRails.configure do |config|
  config.api_key = ENV['FASTLY_API_KEY']  # Fastly api key, required
  config.max_age = 3600                  # 1 hour
  config.service_id = ENV['FASTLY_SERVICE_ID']   # The Fastly service you will be using, required
  config.purging_enabled = Rails.env.production? and ENV['FASTLY_API_KEY'].present?
end