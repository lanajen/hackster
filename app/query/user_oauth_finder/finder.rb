module UserOauthFinder
  class Finder
    def initialize(relation = User)
      @relation = relation
    end

    def find_for_oauth provider, data
      resolver = begin
        "UserOauthFinder::Resolver::#{provider.camelize}".constantize
      rescue NameError
        Resolver::Base
      end

      resolver.new(provider, data, @relation).resolve
    end
  end
end
