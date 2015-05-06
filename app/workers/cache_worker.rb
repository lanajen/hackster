class CacheWorker < BaseWorker
  sidekiq_options queue: :cron, retry: 0

  def warm_cache
    perform_time = Time.now
    Project.indexable.most_popular.pluck(:id).each do |project_id|
      self.class.perform_at perform_time, 'warm_project_cache', project_id
      perform_time += 2.seconds
    end
    self.class.perform_async 'warm_home_cache'
  end

  def warm_project_cache id
    project = Project.find id
    app.get '/' + project.uri unless Rails.cache.exist?(project)
    # fetch_url(APP_CONFIG['full_host'] + '/' + project.uri) unless Rails.cache.exist?(project)
  end

  def warm_home_cache
    app.get root_path unless Rails.cache.exist?('home-visitor')
    # fetch_url(APP_CONFIG['full_host']) unless Rails.cache.exist?('home-visitor')
  end

  private
    def app
      app = ActionDispatch::Integration::Session.new(Rails.application)
      app.host! APP_CONFIG['full_host']
      app.default_url_options = { host: APP_CONFIG['full_host'] }
      default_url_options = { host: APP_CONFIG['full_host'] }
      app
    end

    def fetch_url page_url
      page_url = 'http://' + page_url unless page_url =~ /^https?\:\/\//
      puts "Fetching page #{page_url}..."
      return open(page_url, allow_redirections: :safe, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
      raise "Failed opening page #{page_url}."
    end
end