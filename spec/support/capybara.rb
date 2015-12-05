require 'capybara/rails'
require 'capybara/rspec'

RSpec.configure do |config|
  config.before(:suite) do
    Capybara.app_host = "http://#{APP_CONFIG['full_host']}:#{APP_CONFIG['default_port']}"
    Capybara.asset_host = "http://#{APP_CONFIG['full_host']}:#{APP_CONFIG['default_port']}"
    Capybara.server_port = APP_CONFIG['default_port']
  end
end
