require 'rubygems'
require 'bundler'

$stdout.sync = true
Bundler.require(:rack)

port = (ARGV.first || ENV['PORT'] || 5000).to_i
env = ENV['RACK_ENV'] || 'development'

require 'em-proxy'
require 'logger'
require 'heroku-forward'
require 'heroku/forward/backends/unicorn'

application = File.expand_path('../hackster.ru', __FILE__)
config_file = File.expand_path('../config/server/unicorn.rb', __FILE__)
backend = Heroku::Forward::Backends::Unicorn.new(application: application, env: env, config_file: config_file)
proxy = Heroku::Forward::Proxy::Server.new(backend, host: '0.0.0.0', port: port)
proxy.forward!