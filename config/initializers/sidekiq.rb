require 'sidekiq'
require 'sidekiq-status'

raise 'No config for Redis' unless $redis_config

sidekiq_pool = (ENV['SIDEKIQ_DB_POOL'] || 3).to_i
sidekiq_redis_size = (ENV['SIDEKIQ_REDIS_SIZE'] || 5).to_i

Sidekiq.configure_server do |config|
  config.failures_default_mode = :exhausted
  config.redis = $redis_config.merge({ size: sidekiq_redis_size, namespace: "sidekiq:hacksterio", network_timeout: 8 })

  # database_url = ENV['DATABASE_URL']
  # if database_url
  #   ENV['DATABASE_URL'] = "#{database_url}?pool=8"
  #   ActiveRecord::Base.establish_connection
  # end

  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 30.minutes # default
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end

  if defined?(ActiveRecord::Base)
    Rails.logger.debug("Setting custom connection pool size of #{sidekiq_pool} for Sidekiq Server")
    config = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]
    config['reaping_frequency'] = (ENV['DB_REAP_FREQ'] || 10).to_i # seconds
    config['pool']              = sidekiq_pool + 2  # buffer
    ActiveRecord::Base.establish_connection(config)

    Rails.logger.info("Connection pool size for Sidekiq Server is now: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end

  config.redis = $redis_config.merge({ size: 1, namespace: "sidekiq:hacksterio" })
end

Sidekiq.options[:concurrency] = sidekiq_pool