require 'resque/server'

class ResqueAuthServer < Resque::Server
  before do
    redirect '/' unless request.env['warden'].authenticate? and request.env['warden'].user.is? :admin
  end
end