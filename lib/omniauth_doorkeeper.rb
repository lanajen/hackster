require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Doorkeeper < OmniAuth::Strategies::OAuth2
      option :name, 'doorkeeper'
      option :client_options, {
        site:          'http://www.localhost.local:5000',
        authorize_url: 'http://www.localhost.local:5000/oauth2/authorize'
      }
      option :authorize_options, [:scope]

      uid {
        raw_info['id']
      }

      info do
        prune!({
          email: raw_info['email'],
          image: raw_info['image'],
          name: raw_info['name'],
          nickname: raw_info['user_name'],
        })
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get('http://api.localhost.local:5000/doorkeeper/me').parsed
      end

      def authorize_params
        super.tap do |params|
          %w[scope].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end

          # params[:scope] ||= DEFAULT_SCOPE
        end
      end

      private
        def prune!(hash)
          hash.delete_if do |_, value|
            prune!(value) if value.is_a?(Hash)
            value.nil? || (value.respond_to?(:empty?) && value.empty?)
          end
        end
    end
  end
end