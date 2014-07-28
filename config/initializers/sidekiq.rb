raise 'No config for Redis' unless $redis_config

sidekiq_pool = (ENV['SIDEKIQ_DB_POOL'] || 3).to_i

heroku = nil
if ENV['HEROKU_APP'] and Rails.env == 'staging'
  require 'autoscaler/sidekiq'
  require 'autoscaler/heroku_scaler'
  heroku = Autoscaler::HerokuScaler.new
end

Sidekiq.configure_server do |config|
  if heroku
    config.server_middleware do |chain|
      Rails.logger.info "[Sidekiq] Running on Heroku in staging, autoscaler is used"
      chain.add(Autoscaler::Sidekiq::Server, heroku, 60)  # 60 second timeout
    end
  else
    Rails.logger.info "[Sidekiq] Autoscaler isn't used"
  end

  config.failures_default_mode = :exhausted
  config.redis = $redis_config.merge({ size: 3, namespace: "sidekiq:hacksterio" })

  # database_url = ENV['DATABASE_URL']
  # if database_url
  #   ENV['DATABASE_URL'] = "#{database_url}?pool=8"
  #   ActiveRecord::Base.establish_connection
  # end

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
  if heroku
    config.client_middleware do |chain|
      chain.add Autoscaler::Sidekiq::Client, 'default' => heroku, 'critical' => heroku
    end
  end

  config.redis = $redis_config.merge({ size: 1, namespace: "sidekiq:hacksterio" })
end

Sidekiq.options[:concurrency] = sidekiq_pool