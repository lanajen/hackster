module UrlHelper
  def project_path project, opts={}
    super params_for_project(project).merge(opts)
  end

  def project_url project, opts={}
    super params_for_project(project).merge(opts)
  end

  def url_for(options = nil)
    case options
    when Hash
      if options.has_key?(:subdomain)
        options[:host] = with_subdomain(options.delete(:subdomain))
      end
    when Project
      options = params_for_project options
    end
    super options
  end

  def with_subdomain(subdomain='')
    subdomain += "." unless subdomain.blank?
    [subdomain, request.domain].join
  end

  private
    def params_for_project project
      {
        project_slug: project.slug,
        user_name: project.user_name_for_url,
        use_route: 'project'
      }
    end
end