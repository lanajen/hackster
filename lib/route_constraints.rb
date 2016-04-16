class ApiSite
  def self.matches?(request)
    if ENV['FULL_HOST'].present?
      request.host == ENV['FULL_HOST']
    else
      request.subdomains[0].in? API_SUBDOMAINS and request.domain == APP_CONFIG['default_domain']
    end
  end
end

class NotApiSite
  def self.matches?(request)
    if ENV['FULL_HOST'].present?
      request.host == ENV['FULL_HOST']
    else
      !request.subdomains[0].in? API_SUBDOMAINS or request.domain != APP_CONFIG['default_domain']
    end
  end
end

class MainSite
  def self.matches?(request)
    if ENV['FULL_HOST'].present?
      request.host == ENV['FULL_HOST']
    else
      request.subdomains[0] == ENV['SUBDOMAIN'] and request.domain == APP_CONFIG['default_domain']
    end
  end
end

class ClientSite
  def self.matches?(request)
    if request.domain == APP_CONFIG['default_domain']
      subdomain = request.subdomains[0]
      !subdomain.in? (API_SUBDOMAINS + %w(beta) + [ENV['SUBDOMAIN']])
    else
      site = ClientSubdomain.find_by_domain(request.host).presence and site.enabled? and site.host == request.host
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

class BaseArticlePage
  def self.article_is_type? model, request
    if slug = request.params['project_slug'] and hid = slug.match(/-?([a-f0-9]{6})\Z/)
      project = BaseArticle.find_by_hid(hid[1]) and project.type == model
    elsif id = request.params['id']
      project = BaseArticle.find_by_id(id) and project.type == model
    end
  end
end

class ProjectPage < BaseArticlePage
  def self.matches?(request)
    article_is_type? 'Project', request
  end
end

class ExternalProjectPage < BaseArticlePage
  def self.matches?(request)
    article_is_type? 'ExternalProject', request
  end
end

class ArticlePage < BaseArticlePage
  def self.matches?(request)
    article_is_type? 'Article', request
  end
end

class ShortLinkDomain
  def self.matches?(request)
    request.domain == ENV['SHORT_LINK_DOMAIN']
  end
end

class NotShortLinkDomain
  def self.matches?(request)
    request.domain != ENV['SHORT_LINK_DOMAIN']
  end
end

class MouserContest
  def self.matches?(request)
    request.subdomains[0] == 'mousercontest' and request.domain == APP_CONFIG['default_domain']
  end
end

class IntelLandingPage
  def self.matches?(request)
    request.subdomains[0] == 'chinausyoungmakercompetition' and request.domain == APP_CONFIG['default_domain']
  end
end