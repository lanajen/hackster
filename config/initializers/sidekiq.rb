raise 'No config for Redis' unless $redis_config

sidekiq_pool = ENV['SIDEKIQ_DB_POOL'].to_i || 3

Sidekiq.configure_server do |config|
  config.failures_default_mode = :exhausted
  config.redis = $redis_config.merge({ size: 3 })

  # database_url = ENV['DATABASE_URL']
  # if database_url
  #   ENV['DATABASE_URL'] = "#{database_url}?pool=8"
  #   ActiveRecord::Base.establish_connection
  # end

  if defined?(ActiveRecord::Base)
    Rails.logger.debug("Setting custom connection pool size of #{sidekiq_pool} for Sidekiq Server")
    config = Rails.application.config.database_configuration[Rails.env]
    config['reaping_frequency'] = ENV['DB_REAP_FREQ'].to_i || 10 # seconds
    config['pool']              = sidekiq_pool + 2  # buffer
    ActiveRecord::Base.establish_connection(config)

    Rails.logger.info("Connection pool size for Sidekiq Server is now: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
  end
end

Sidekiq.configure_client do |config|
  config.redis = $redis_config.merge({ size: 1 })
end

Sidekiq.options[:concurrency] = sidekiq_pool