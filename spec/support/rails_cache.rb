RSpec.configure do |config|
  config.after(:suite) do
    Rails.cache.clear
  end
end
