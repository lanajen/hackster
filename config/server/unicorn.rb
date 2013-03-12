# Unicorn configuration file to be running by unicorn_init.sh with capistrano task
# read an example configuration before: http://unicorn.bogomips.org/examples/unicorn.conf.rb
#
# working_directory, pid, paths - internal Unicorn variables must to setup
# worker_process 4              - is good enough for serve small production application
# timeout 30                    - time limit when unresponded workers to restart
# preload_app true              - the most interesting option that confuse a lot of us,
#                                 just setup is as true always, it means extra work on
#                                 deployment scripts to make it correctly
# BUNDLE_GEMFILE                - make Gemfile accessible with new master
# before_fork, after_fork       - reconnect to all dependent services: DB, Redis, Sphinx etc.
#                                 deal with old_pid only if CPU or RAM are limited enough
#
# config/server/production/unicorn.rb

app_name          = 'halckemy'
#app_path          = "/var/www/#{app_name}"
#
#working_directory "#{app_path}/current"
#pid               "#{app_path}/shared/pids/unicorn.pid"
#stderr_path       "#{app_path}/shared/log/unicorn.log"
#stdout_path       "#{app_path}/shared/log/unicorn.log"
#
#listen            "/tmp/#{app_name}.unicorn.production.sock"
worker_processes  4
timeout           30
preload_app       true

#before_exec do |server|
#  ENV["BUNDLE_GEMFILE"] = "#{app_path}/current/Gemfile"
#end

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end

  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end

  sleep 1
end

#redis = YAML::load(File.open(File.join(Rails.root, 'config/server/redis.yml')))[Rails.env]

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end

  if defined?(Resque)
    redis_conf = YAML::load(File.open(File.join(Rails.root, 'config/server/redis.yml')))[Rails.env]
    if ENV['REDISTOGO_URL'].present?
      Resque.redis = ENV['REDISTOGO_URL']
    else
      if redis_conf['login'].present?
        Resque.redis = "#{redis_conf['login']}:#{redis_conf['password']}@#{redis_conf['host']}:#{redis_conf['port']}"
      else
        Resque.redis = "#{redis_conf['host']}:#{redis_conf['port']}"
      end
    end
    Resque.redis.namespace = "resque:#{app_name}"
    Rails.logger.info('Connected to Redis')
  end
end