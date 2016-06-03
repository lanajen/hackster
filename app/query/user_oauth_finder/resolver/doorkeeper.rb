module UserOauthFinder
  module Resolver
    class Doorkeeper < Base
      def resolve
        if user = @relation.find_by_id(data.uid)
          user.match_by = 'uid'
          user
        end
      end
    end
  end
end