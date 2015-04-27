class CacheWorker < BaseWorker
  def turn_up_the_heat
    app = ActionDispatch::Integration::Session.new(Rails.application)
    app.host! APP_CONFIG['full_host']
    app.default_url_options = { host: APP_CONFIG['full_host'] }
    default_url_options = { host: APP_CONFIG['full_host'] }

    Project.indexable.most_popular.each do |project|
      app.get '/' + project.uri unless Rails.cache.exist?(project)
    end
    app.get root_path unless Rails.cache.exist?('home-visitor')
  end
end