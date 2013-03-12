require 'resque'
#require 'resque_scheduler'

config = YAML::load(File.open(File.join(Rails.root, 'config/server/redis.yml')))[Rails.env]
#cron = YAML.load_file(Rails.root.join('config', 'cron.yml'))

# configure redis connection
if ENV['REDISTOGO_URL'].present?
  Resque.redis = ENV['REDISTOGO_URL']
else
  if config['login'].present?
    Resque.redis = "#{config['login']}:#{config['password']}@#{config['host']}:#{config['port']}"
  else
    Resque.redis = "#{config['host']}:#{config['port']}"
  end
end

# configure the schedule
#Resque.schedule = cron

# set a custom namespace for redis (optional)
Resque.redis.namespace = "resque:halckemy"

Resque.before_fork = Proc.new {
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end
  sleep 1
}

Resque.after_fork = Proc.new {
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
}