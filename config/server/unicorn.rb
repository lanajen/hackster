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
# if ENV['RAILS_ENV'] == 'development'
#   worker_processes 1
# else
#   worker_processes 3
# end
# timeout           29
# preload_app       true

# #before_exec do |server|
# #  ENV["BUNDLE_GEMFILE"] = "#{app_path}/Gemfile"
# #end

# before_fork do |server, worker|
#   if defined?(ActiveRecord::Base)
#     ActiveRecord::Base.connection.disconnect!
#     Rails.logger.info('Disconnected from ActiveRecord')
#   end

#   # if defined?(Resque)
#   #   ResqueRedis.disconnect
#   # end

#   sleep 1
# end

# after_fork do |server, worker|
#   if defined?(ActiveRecord::Base)
#     ActiveRecord::Base.establish_connection
#     Rails.logger.info('Connected to ActiveRecord')
#   end

# #   if defined?(Resque)
# # #    I18nRedisBackend.connect
# #     ResqueRedis.connect
# #   end
# end

if ENV['RAILS_ENV'] == 'development'
  worker_processes 2
  # timeout 120
else
  worker_processes Integer(ENV["WEB_CONCURRENCY"] || 2)
  timeout 29
end

# The timeout mechanism in Unicorn is an extreme solution that should be avoided whenever possible.
# It will help catch bugs in your application where and when your application forgets to use timeouts,
# but it is expensive as it kills and respawns a worker process.
# see http://unicorn.bogomips.org/Application_Timeouts.html

# Heroku recommends a timeout of 15 seconds. With a 15 second timeout, the master process will send a
# SIGKILL to the worker process if processing a request takes longer than 15 seconds. This will
# generate a H13 error code and you’ll see it in your logs. Note, this will not generate any stacktraces
# to assist in debugging. Using Rack::Timeout, we can get a stacktrace in the logs that can be used for
# future debugging, so we set that value to something less than this one

preload_app true # for new relic

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  Rails.logger.info("Done forking unicorn processes")

  #https://devcenter.heroku.com/articles/concurrency-and-database-connections
  if defined?(ActiveRecord::Base)

    db_pool_size = if ENV["DB_POOL"]
      ENV["DB_POOL"]
    else
      ENV["WEB_CONCURRENCY"] || 2
    end

    config = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]
    config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
    config['pool']              = ENV['DB_POOL'] || 2
    ActiveRecord::Base.establish_connection(config)

    # Turning synchronous_commit off can be a useful alternative when performance is more important than exact certainty about the durability of a transaction
    # ActiveRecord::Base.connection.execute "update pg_settings set setting='off' where name = 'synchronous_commit';"

    Rails.logger.info("Connection pool size for unicorn is now: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
  end

end