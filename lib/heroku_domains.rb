require 'heroku-api'

module HerokuDomains
  module Manager
    class << self
      @@heroku = Heroku::API.new(api_key: ENV['HEROKU_API_KEY'],
        mock: Rails.env == 'development')

      def add_domain(domain)
        begin
          @@heroku.post_domain(ENV['HEROKU_APP'], domain)
        rescue => e
          Rails.logger.error "Error in heroku_domains/add_domain: #{e.inspect}"
        end
      end

      def remove_domain(domain)
        begin
          @@heroku.delete_domain(ENV['HEROKU_APP'], domain)
        rescue => e
          Rails.logger.error "Error in heroku_domains/remove_domain: #{e.inspect}"
        end
      end
    end
  end

  def add_domain_to_heroku domain
    Manager.add_domain domain
    Rails.logger.info "Added domain to heroku: #{domain}"
  end

  def remove_domain_from_heroku domain
    Manager.remove_domain domain
    Rails.logger.info "Removed domain from heroku: #{domain}"
  end
end