class Subdomain < ActiveRecord::Base
  def full_domain
    port = APP_CONFIG['port_required'] ? ":#{APP_CONFIG['default_port']}" : nil
    "#{host}#{port}"
  end

  def host
    if domain.present?
      domain
    else
      out = subdomain + '.'
      if ENV['SUBDOMAIN'].present? and ENV['SUBDOMAIN'] != 'www'
        out << ENV['SUBDOMAIN'] + '.'
      end
      out << APP_CONFIG['default_domain']
      out
    end
  end

  def uses_subdomain?
    domain.blank?
  end
end
