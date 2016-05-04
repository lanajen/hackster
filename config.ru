# This file is used by Rack-based servers to start the application.

require File.expand_path('../config/environment',  __FILE__)

run HackerIo::Application

if Rails.env.development?
  HackerIo::Application.load_tasks
  Rake::Task['assets:webpack'].invoke
end