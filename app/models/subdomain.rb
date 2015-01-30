class Subdomain < ActiveRecord::Base
  def full_domain
    domain.present? ? domain : "#{subdomain}.#{APP_CONFIG['default_domain']}"
  end
end
