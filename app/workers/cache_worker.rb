class CacheWorker < BaseWorker
  def warm_cache
    Project.indexable.most_popular.pluck(:id).each do |project_id|
      self.class.perform_async 'warm_project_cache', project_id
    end
    self.class.perform_async 'warm_home_cache'
  end

  def warm_project_cache id
    project = Project.find id
    app.get '/' + project.uri unless Rails.cache.exist?(project)
  end

  def warm_home_cache
    app.get root_path unless Rails.cache.exist?('home-visitor')
  end

  private
    def app
      app = ActionDispatch::Integration::Session.new(Rails.application)
      app.host! APP_CONFIG['full_host']
      app.default_url_options = { host: APP_CONFIG['full_host'] }
      default_url_options = { host: APP_CONFIG['full_host'] }
      app
    end
end