require 'resque/tasks'
#require 'resque_scheduler/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
  Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
end

task "jobs:work" => "resque:work"