require 'resque/tasks'
require 'resque_scheduler/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] ||= '*'
  Resque.after_fork = Proc.new do
    ActiveRecord::Base.establish_connection
    ResqueRedis.reconnect
  end
end

task "jobs:work" => "resque:work"