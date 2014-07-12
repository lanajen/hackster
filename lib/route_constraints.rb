class ApiSite
  def self.matches?(request)
    request.subdomains[0] == 'api'
  end
end

class MainSite
  def self.matches?(request)
    request.subdomains[0] == 'www'
  end
end

class ClientSite
  def self.matches?(request)
    subdomain = request.subdomains[0]
    !subdomain.in? %w(www beta)
  end
end

class PageWithSlug
  def self.sluggable_is_model? model, request
    return false unless slug = request.params['slug'].try(:downcase)
    slug = SlugHistory.find_by_value(slug) and slug.sluggable.class.name == model
  end
end

class TechPage < PageWithSlug
  def self.matches?(request)
    sluggable_is_model? 'Tech', request
  end
end

class UserPage < PageWithSlug
  def self.matches?(request)
    sluggable_is_model? 'User', request
  end
end