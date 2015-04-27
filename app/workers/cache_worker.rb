class CacheWorker < BaseWorker
  def turn_up_the_heat
    app.host! APP_CONFIG['full_host']
    Project.indexable.each do |project|
      app.get '/' + project.uri unless Rails.cache.exist?(project)
    end
    app.get '/' unless Rails.cache.exist?('home-visitor')
  end
end