require 'resque'
require 'resque_scheduler'

cron = YAML.load_file(Rails.root.join('config', 'cron.yml'))

# configure the schedule
#Resque.schedule = cron

Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }

# configure redis connection
module ResqueRedis
  def self.connect
    raise 'No config for Redis' unless $redis_config
    Resque.redis = Redis.new $redis_config
    # set a custom namespace for redis
    Resque.redis.namespace = "resque:halckemy"
    Rails.logger.info('Resque connected to Redis')
  end

  def self.disconnect
    Resque.redis.quit
    Rails.logger.info('Resque disconnected from Redis')
  end
end

ResqueRedis.connect