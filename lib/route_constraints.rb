class ApiSite
  def self.matches?(request)
    request.subdomains[0] == 'api' and request.domain == APP_CONFIG['default_domain']
  end
end

class MainSite
  def self.matches?(request)
    request.subdomains[0].in? %w(staging www dev) and request.domain == APP_CONFIG['default_domain']
  end
end

class ClientSite
  def self.matches?(request)
    if request.domain == APP_CONFIG['default_domain']
      subdomain = request.subdomains[0]
      !subdomain.in? %w(www beta staging dev)
    else
      ClientSubdomain.find_by_domain(request.host).present?
    end
  end
end

class PageWithSlug
  def self.sluggable_is_model? model, request
    return false unless slug = request.params['slug'].try(:downcase)
    slug = SlugHistory.find_by_value(slug) and slug.sluggable.class.name == model
  end
end

class PlatformPage < PageWithSlug
  def self.matches?(request)
    sluggable_is_model? 'Platform', request
  end
end

class UserPage < PageWithSlug
  def self.matches?(request)
    sluggable_is_model? 'User', request
  end
end