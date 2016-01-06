class Subdomain < ActiveRecord::Base
  def full_domain
    port = APP_CONFIG['port_required'] ? ":#{APP_CONFIG['default_port']}" : nil
    "#{host}#{port}"
  end

  def host
    domain.present? ? domain : "#{subdomain}.#{APP_CONFIG['default_domain']}"
  end
end
