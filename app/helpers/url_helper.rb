module UrlHelper
  def with_subdomain(subdomain='')
    subdomain += "." unless subdomain.blank?
    [subdomain, request.domain].join
  end

  def url_for(options = nil)
    if options.kind_of?(Hash)
      if options.has_key?(:subdomain)
        options[:host] = with_subdomain(options.delete(:subdomain))
      end
    end
    super options
  end
end