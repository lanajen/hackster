class MainSite
  def self.matches?(request)
    request.subdomains[0] == 'www'
  end
end

class ClientSite
  def self.matches?(request)
    subdomain = request.subdomains[0]
    subdomain != 'www' and ClientSubdomain.find_by_subdomain(subdomain)
  end
end