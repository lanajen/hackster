# Unicorn configuration file to be running by unicorn_init.sh with capistrano task
# read an example configuration before: http://unicorn.bogomips.org/examples/unicorn.redis_conf.rb
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

app_name          = 'hackerio'

#
#working_directory ""
#pid               "/pids/unicorn.pid"
#stderr_path       "/log/unicorn.log"
#stdout_path       "/log/unicorn.log"

#listen            "/tmp/#{app_name}.unicorn.production.sock"
if ENV['RAILS_ENV'] == 'development'
  worker_processes 1
else
  worker_processes 3
end
timeout           30
preload_app       true

#before_exec do |server|
#  ENV["BUNDLE_GEMFILE"] = "#{app_path}/Gemfile"
#end

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end

  # if defined?(Resque)
  #   ResqueRedis.disconnect
  # end

  sleep 1
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end

#   if defined?(Resque)
# #    I18nRedisBackend.connect
#     ResqueRedis.connect
#   end
end