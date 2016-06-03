module UserOauthFinder
  class Finder
    def initialize(relation = User)
      @relation = relation
    end

    def find_for_oauth provider, data
      resolver = begin
        "UserOauthFinder::Resolver::#{provider.camelize}".constantize
      rescue
        Resolver::Base
      end

      resolver.new(provider, data, @relation).resolve
    end
  end

  module Resolver
    class Base
      attr_accessor :data, :provider

      def initialize provider, data, relation
        @provider = provider
        @data = data
        @relation = relation
      end

      def resolve
        uid = data.uid

        if user = find_for_oauth_by_uid(provider, uid)
          user.match_by = 'uid'
          return user
        end

        attributes = SocialProfile::Builder.new(provider, data).social_profile_attributes  # let this handle extracting the data
        email = attributes.email

        if email and user = @relation.where(email: email, invitation_token: nil).first
          user.match_by = 'email'
          return user
        end

        nil
      end

      private
        def find_for_oauth_by_uid(provider, uid)
          @relation.where('authorizations.uid = ? AND authorizations.provider = ?', uid.to_s, provider).joins(:authorizations).readonly(false).first
        end
    end
  end
end
