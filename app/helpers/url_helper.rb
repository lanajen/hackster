module UrlHelper
  def group_path group, opts={}
    super params_for_group(group).merge(opts)
  end

  def group_url group, opts={}
    super params_for_group(group).merge(opts)
  end

  def project_path project, opts={}
    super params_for_project(project).merge(opts)
  end

  def project_url project, opts={}
    super params_for_project(project).merge(opts)
  end

  def project_embed_url project, opts={}
    force_params = { use_route: 'project_embed' }
    super params_for_project(project, force_params).merge(opts)
  end

  def tech_path tech, opts={}
    super params_for_group(tech, 'tech').merge(opts)
  end

  def tech_url tech, opts={}
    super params_for_group(tech, 'tech').merge(opts)
  end

  def url_for(options = nil)
    case options
    when Hash
      if options.has_key?(:subdomain)
        options[:host] = with_subdomain(options.delete(:subdomain))
      end
    # when Group
    #   options = params_for_group options
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
    def params_for_group group, route='group'
      {
        user_name: group.user_name,
        use_route: route
      }
    end

    def params_for_project project, force_params={}
      {
        project_slug: project.slug,
        user_name: project.user_name_for_url,
        use_route: 'project'
      }.merge(force_params)
    end
end