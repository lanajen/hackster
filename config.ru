# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
use Rack::Static, :urls => ['/carrierwave'], :root => 'tmp'
if Rails.env.profile?
  use Rack::RubyProf, :path => '/tmp/profile'
end

require 'faye'
require 'faye/redis'
require File.expand_path('../config/initializers/0_redis', __FILE__)
require File.expand_path('../lib/faye_extensions/csrf_protection', __FILE__)
require File.expand_path('../lib/faye_extensions/authentication', __FILE__)
require File.expand_path('../lib/faye_extensions/client_event', __FILE__)

# Load a WebSocket adapter for whichever server you're using
Faye::WebSocket.load_adapter 'puma'

use Faye::RackAdapter,
      mount: '/faye',
      engine: { type: Faye::Redis, namespace: 'faye' }.merge($redis_config),
      timeout: 25,
      server: 'puma'#,
      # extensions: [
        # Faye::Authentication.new,
        # Faye::CsrfProtection.new,
        # Faye::ClientEvent.new,
      #   ] do
      #   map '/chats/*' => Faye::ChatsController
      #   map default: :block
      # end

run HackerIo::Application