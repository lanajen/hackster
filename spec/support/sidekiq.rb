RSpec::Sidekiq.configure do |config|
  config.clear_all_enqueued_jobs = true
  config.enable_terminal_colours = true
  config.warn_when_jobs_not_processed_by_sidekiq = true
end

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end
