# This file is used by Rack-based servers to start the application.

require File.expand_path('../config/environment',  __FILE__)
use Rack::Static, :urls => ['/carrierwave'], :root => 'tmp'
if Rails.env.profile?
  use Rack::RubyProf, :path => '/tmp/profile'
end

run HackerIo::Application

if Rails.env.development?
  HackerIo::Application.load_tasks
  Rake::Task['assets:webpack'].invoke
end