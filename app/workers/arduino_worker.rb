class ArduinoWorker < BaseWorker
  def add_project_url_to_sketch sketch_url, project_id
    project = Project.find project_id
    site = Platform.find_by_user_name('arduino').client_subdomain
    generator = UrlGenerator.new(host: site.host, path_prefix: site.path_prefix, current_site: site)
    project_url = generator.project_url(project)
    user = project.users.first
    ArduinoApiClient.new(user).add_tutorial_url_to_sketch(sketch_url, project_url)
  end
end