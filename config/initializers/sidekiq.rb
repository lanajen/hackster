raise 'No config for Redis' unless $redis_config

Sidekiq.configure_server do |config|
  config.redis = $redis_config.merge({ size: 3 })

  database_url = ENV['DATABASE_URL']
  if database_url
    ENV['DATABASE_URL'] = "#{database_url}?pool=8"
    ActiveRecord::Base.establish_connection
  end
  config.failures_default_mode = :exhausted
end

Sidekiq.configure_client do |config|
  config.redis = $redis_config.merge({ size: 1 })
end