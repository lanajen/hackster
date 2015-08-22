redis = Redis::Namespace.new 'split:hacksterio', redis: RedisConn.conn
Split.redis = redis

Split.configure do |config|
  config.db_failover = true  # handle redis errors gracefully
  config.db_failover_on_db_error = proc{|error| Rails.logger.error(error.message) }
  config.allow_multiple_experiments = true
  config.enabled = true
  config.experiments = YAML.load_file 'config/split.yml'
end